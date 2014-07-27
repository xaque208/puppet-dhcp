# Define: dhcp::conf
#
# A simple define to ensure that any sub configuration files generated
# are included only when they are needed.
#
define dhcp::conf {

  include dhcp::params

  $dhcp_dir = $dhcp::params::dhcp_dir
  $content  = inline_template("include \"${name}\";")

  concat::fragment { "dhcp-conf-${name}":
    target  => "${dhcp_dir}/dhcpd.conf",
    content => $content,
    order   => '99',
  }
}
