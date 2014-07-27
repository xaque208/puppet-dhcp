# Class: dhcp::conf::pools
#
# Dependencies for all dhcp::pools resources.  Builds the dhcp.pools
# file.
#
class dhcp::conf::pools (
  $dhcp_dir    = $dhcp::params::dhcp_dir,
  $servicename = $dhcp::params::servicename,
) inherits dhcp::params {

  include concat::setup

  dhcp::conf {"${dhcp_dir}/dhcpd.pools": }

  # Build the dhcpd.pools
  concat { "${dhcp_dir}/dhcpd.pools":
    notify => Service[$servicename],
  }

  concat::fragment { 'dhcp-pools-header':
    target  => "${dhcp_dir}/dhcpd.pools",
    content => "# DHCP pools\n",
    order   => '01',
  }
}
