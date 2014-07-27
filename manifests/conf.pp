# Define: dhcp::conf
#
# A simple define to ensure that any sub configuration files generated
# are included only when they are needed.
#
define dhcp::conf {

  $content = inline_template("include \"${name}\";")

  concat::fragment { "dhcp-conf-${name}":
    target  => $name,
    content => $content,
    order   => '99',
  }
}
