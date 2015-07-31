# === Class: bind::service
#
# This class takes care of services and
# writes our named.conf file.
#
# === Parameters
#
# $forwarders: The servers to forward requests that can't be answered
#              cand be empty.
#
# Doug Morris <dmorris@covermymeds.com
#
# === Copyright
#
# Copyright 2015 CoverMyMeds, unless otherwise noted
#

class bind::service (
  $forwarders = []
) {
  validate_array($forwarders)

  $bind_domains = hiera_hash('bind::domains')
  $acls = hiera('bind::acls')

  case $::operatingsystemmajrelease {
    '6': {$restartcommand = '/usr/sbin/named-checkconf -z && /etc/init.d/named restart'
          $reloadcommand = '/usr/sbin/named-checkconf -z && /etc/init.d/named reload'
          $service_name = 'named' }
    '7': {$restartcommand = '/usr/sbin/named-checkconf -z && /usr/bin/systemctl restart named-chroot'
          $reloadcommand = '/usr/sbin/named-checkconf -z && /usr/bin/systemctl reload named-chroot'
          $service_name = 'named-chroot' }
    default: { fail("Unsupported OS release: ${::operatingsystemmajrelease}") }
  }

  service { $service_name:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => File['/etc/named.conf'],
  }

  file{'/etc/named.conf':
    mode    => '0640',
    owner   => root,
    group   => named,
    require => Package['bind', 'bind-chroot'],
    content => template('bind/named_conf.erb'),
    notify  => Exec['named_restart'],
  }

  # Safer restart for the named daemon on config update
  exec{'named_restart':
    refreshonly => true,
    command     => $restartcommand,
  }

  # Use reload instead of restart for zone updates
  exec{'zone_reload':
    refreshonly => true,
    command     => $reloadcommand,
  }

}
