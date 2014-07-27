define dhcp::pool (
  $network,
  $mask,
  $range,
  $gateway,
  $failover   = '',
  $options    = '',
  $parameters = '',
) inherits dhcp::params {

  include dhcp::params
  include dhcp::conf::pools

  $dhcp_dir = $dhcp::params::dhcp_dir

  validate_hash($options)
  validate_hash($parameters)

  concat::fragment { "dhcp_pool_${name}":
    target  => "${dhcp_dir}/dhcpd.pools",
    content => template('dhcp/dhcpd.pool.erb'),
    order   => '10',
    notify  => Service[$servicename],
  }
}
