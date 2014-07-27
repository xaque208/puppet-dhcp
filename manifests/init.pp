# Class: dhcp
#
# Configure a DHCP server
#
# Paramaters:
#  $authoratative
#  $dnsdomain
#  $nameservers
#  $ntpservers
#  $dhcp_conf_header
#  $dhcp_conf_pxe
#  $dhcp_conf_extra
#  $dhcp_conf_fragments
#  $interfaces
#  $pxeserver
#  $pxefilename
#  $logfacility
#  $default_lease_time
#  $max_lease_time
#  $failover
#  $ddns
#  $dhcp_dir
#  $packagename
#  $servicename
#  $dhcpd
#
class dhcp (
  $authoratative       = true,
  $dnsdomain           = '',
  $nameservers         = [],
  $ntpservers          = [],
  $dhcp_conf_header    = 'dhcp/dhcpd.conf-header.erb', # default template
  $dhcp_conf_pxe       = 'dhcp/dhcpd.conf.pxe.erb',    # default template
  $dhcp_conf_extra     = 'dhcp/dhcpd.conf-extra.erb',  # default template
  $dhcp_conf_fragments = {},
  $interfaces          = undef,
  $pxeserver           = undef,
  $pxefilename         = undef,
  $logfacility         = 'daemon',
  $default_lease_time  = 3600,
  $max_lease_time      = 86400,
  $failover            = '',
  $ddns                = false,
  $dhcp_dir            = $dhcp::params::dhcp_dir,
  $packagename         = $dhcp::params::packagename,
  $servicename         = $dhcp::params::servicename,
  $dhcpd               = $dhcp::params::dhcpd,
) inherits dhcp::params {


  # Incase people set interface instead of interfaces work around
  # that. If they set both, use interfaces and the user is a unwise
  # and deserves what they get.
  if $interface != undef and $interfaces == undef {
    $dhcp_interfaces = [ $interface ]
  } elsif $interface == undef and $interfaces == undef {
    fail ("You need to set \$interfaces in ${module_name}")
  } else {
    $dhcp_interfaces = $interfaces
  }



  if $packagename {
    package { $packagename:
      ensure => installed,
    }
  }

  # OS Specifics
  case $::operatingsystem {
    'debian','ubuntu': {
      include dhcp::debian
    }
    'openbsd': {
      #include dhcp::openbsd
    }
  }

  include concat::setup

  #
  # Build up the dhcpd.conf
  concat {  "${dhcp_dir}/dhcpd.conf": }

  concat::fragment { 'dhcp-conf-header':
    target  => "${dhcp_dir}/dhcpd.conf",
    content => template($dhcp_conf_header),
    order   => 01,
  }

  concat::fragment { 'dhcp-conf-pxe':
    target  => "${dhcp_dir}/dhcpd.conf",
    content => template($dhcp_conf_pxe),
    order   => 20,
  }

  concat::fragment { 'dhcp-conf-extra':
    target  => "${dhcp_dir}/dhcpd.conf",
    content => template($dhcp_conf_extra),
    order   => 99,
  }

  # Using DDNS will require a dhcp::ddns class composition, else, we should
  # turn it off.
  unless ( $ddns ) {
    class { 'dhcp::ddns': enable => false; }
  }

  # Any additional dhcpd.conf fragments the user passed in as a hash for
  # create_resources.  This allows the end user almost total control over the
  # DHCP server without modifying this module at all.

  # JJM This is commented out because the create_resources in PE does not
  # support the third option.
  # $fragment_defaults = {
  #   content => "# Managed by Puppet\n",
  #   target  => "${dhcp_dir}/dhcpd.conf",
  #   order   => 80,
  # }
  create_resources('concat::fragment', $dhcp_conf_fragments)

  #
  # Build the dhcpd.pools
  concat { "${dhcp_dir}/dhcpd.pools": }

  concat::fragment { 'dhcp-pools-header':
    target  => "${dhcp_dir}/dhcpd.pools",
    content => "# DHCP Pools\n",
    order   => 01,
  }

  #
  # Build the dhcpd.hosts
  concat { "${dhcp_dir}/dhcpd.hosts": }

  concat::fragment { 'dhcp-hosts-header':
    target  => "${dhcp_dir}/dhcpd.hosts",
    content => "# static DHCP hosts\n",
    order   => 01,
  }

  service { $servicename:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    subscribe => [
      Concat["${dhcp_dir}/dhcpd.pools"],
      Concat["${dhcp_dir}/dhcpd.hosts"],
      File["${dhcp_dir}/dhcpd.conf"]
    ],
    restart   => "${dhcpd} -t && service ${servicename} restart",
    require   => Package[$packagename],
  }

  include dhcp::monitor
}
