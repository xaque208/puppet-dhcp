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
#  $default_lease_time
#  $max_lease_time
#  $failover
#  $ddns
#  $logfacility
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
  $interface           = undef,
  $pxeserver           = undef,
  $pxefilename         = undef,
  $default_lease_time  = 3600,
  $max_lease_time      = 86400,
  $failover            = '',
  $ddns                = false,
  $logfacility         = $dhcp::params::logfacility,
  $dhcp_dir            = $dhcp::params::dhcp_dir,
  $packagename         = $dhcp::params::packagename,
  $servicename         = $dhcp::params::servicename,
  $dhcpd               = $dhcp::params::dhcpd,
  $conftest            = $dhcp::params::conftest,
) inherits dhcp::params {

  include concat::setup

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
  #
  # Build up the dhcpd.conf
  concat {  "${dhcp_dir}/dhcpd.conf":
    notify => Service[$servicename],
  }

  concat::fragment { 'dhcp-conf-header':
    target  => "${dhcp_dir}/dhcpd.conf",
    content => template($dhcp_conf_header),
    order   => 01,
  }

  concat::fragment { 'dhcp-conf-pxe':
    target  => "${dhcp_dir}/dhcpd.conf",
    content => template($dhcp_conf_pxe),
    order   => '20',
  }

  concat::fragment { 'dhcp-conf-extra':
    target  => "${dhcp_dir}/dhcpd.conf",
    content => template($dhcp_conf_extra),
    order   => '98',
  }

  # Using DDNS will require a dhcp::ddns class composition, else, we
  # should turn it off.
  unless ($ddns) {
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

  service { $servicename:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => "${conftest} && service ${servicename} restart",
    require => $packagename ? {
      undef   => undef,
      default => Package[$packagename],
    }
  }
}
