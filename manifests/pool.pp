define dhcp::pool (
  $network,
  $mask,
  $range,
  $gateway,
  $failover   = '',
  $options    = '',
  $parameters = '',
  $dhcp_dir   = $dhcp::params::dhcp_dir
) inherits dhcp::parmas {

  include dhcp::conf::pools

  validate_hash($options)
  validate_hash($parameters)

  concat::fragment { "dhcp_pool_${name}":
    target  => "${dhcp_dir}/dhcpd.pools",
    content => template('dhcp/dhcpd.pool.erb'),
    order   => '10',
    notify  => Service[$servicename],
  }
}
