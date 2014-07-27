# Class: dhcp::params
#
# Set some paramaters for the curernt platform.
#
class dhcp::params {

  case $::operatingsystem {
    'debian': {
      $dhcp_dir    = '/etc/dhcp'
      $packagename = 'isc-dhcp-server'
      $servicename = 'isc-dhcp-server'
      $dhcpd       = '/usr/sbin/dhcpd'
      $logfacility = 'daemon'
    }
    'ubuntu': {
      if versioncmp($::operatingsystemrelease, '12.04') >= 0 {
        $dhcp_dir    = '/etc/dhcp'
      } else {
        $dhcp_dir    = '/etc/dhcp3'
        $dhcpd       = '/usr/sbin/dhcpd'
      }
      $packagename = 'isc-dhcp-server'
      $servicename = 'isc-dhcp-server'
      $logfacility = 'daemon'
    }
    'darwin': {
      $dhcp_dir    = '/opt/local/etc/dhcp'
      $packagename = 'dhcp'
      $servicename = 'org.macports.dhcpd'
      $logfacility = 'daemon'
    }
    'freebsd': {
      $dhcp_dir    = '/usr/local/etc'
      $packagename = 'net/isc-dhcp42-server'
      $servicename = 'isc-dhcpd'
      $dhcpd       = '/usr/local/sbin/dhcpd'
      $logfacility = 'daemon'
    }
    'openbsd': {
      $dhcp_dir    = '/etc'
      #$packagename = undef # Use dhcpd(8) from base
      $packagename = 'isc-dhcp-server'
      $servicename = 'dhcpd'
      $dhcpd       = '/usr/local/sbin/dhcpd'
      $logfacility = 'daemon' # Not supported on OpenBSD
    }
    'redhat','fedora','centos': {
      $dhcp_dir    = '/etc/dhcp'
      $packagename = 'dhcp'
      $servicename = 'dhcpd'
      $logfacility = 'daemon'
    }
  }

  $conftest = $::operatingsystem ? {
    'OpenBSD' => "${dhcpd} -n",
    default   => "${dhcpd} -t",
  }
}
