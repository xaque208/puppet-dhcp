# Class: dhcp::conf::hosts
#
# Dependencies for all dhcp::host resources.  Builds the dhcp.hosts file.
#
class dhcp::conf::hosts (
  $dhcp_dir    = $dhcp::params::dhcp_dir,
  $servicename = $dhcp::params::servicename,
) inherits dhcp::params {

  include concat::setup

  # Build the dhcpd.hosts
  concat { "${dhcp_dir}/dhcpd.hosts":
    notify => Service[$servicename],
  }

  concat::fragment { 'dhcp-hosts-header':
    target  => "${dhcp_dir}/dhcpd.hosts",
    content => "# static DHCP hosts\n",
    order   => '01',
  }
}
