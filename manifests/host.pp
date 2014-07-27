# ----------
# Host Reservation
# ----------
define dhcp::host (
  $ip,
  $mac,
  $comment     = '',
  $host        = $name,
  $dhcp_dir    = $dhcp::params::dhcp_dir,
  $servicename = $dhcp::params::servicename,
) inherits dhcp::parmas {

  include dhcp::conf::hosts

  concat::fragment { "dhcp_host_${name}":
    target  => "${dhcp_dir}/dhcpd.hosts",
    content => template('dhcp/dhcpd.host.erb'),
    order   => '10',
    notify  => Service[$servicename],
  }
}
