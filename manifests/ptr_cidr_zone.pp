# === Define: bind::ptr_cidr_zone
#
# Creates and adds reverse zone files for the Bind server
#
# === Authors
#
# Doug Morris <dmorris@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds, unless otherwise noted
#
define bind::ptr_cidr_zone (
  $nameservers,
  $zone         = $title,
  $ttl          = 3600,
  $refresh      = 10800,
  $retry        = 3600,
  $expire       = 604800,
  $negresp      = 300,
) {

  $cidr_ptr = inline_template('<%= @name.chomp("0/24").split(".").reverse.join(".").concat(".in-addr.arpa") %>')
  $query_zone = chop($zone)

  # Pull the cidr_ptr_zones from ipam
  $cidr_ptr_zone = parsejson(dns_array($::bind::data_src, $::bind::data_name, $::bind::data_key, $query_zone, $::bind::use_ipam))

  # Select the invalid cidr_ptr_zones and warn about them.
  # Refer to RFC-1034
  #$_invalid_cidr_ptr_zone = $cidr_ptr_zone.filter |$keys, $values| { $keys !~ /^[a-zA-Z0-9.\-]*$/ }
  #notify { "${zone} test ${_invalid_cidr_ptr_zone}": }

  #$_invalid_cidr_ptr_zone.each |$key, $value| {
  #  notify { "bind_validation_failure\: The hostname for \'${key}\' in \'${zone}\' has an invalid value=\'${value}\'": }
  #}

  # Select only the valid cidr_ptr_zones so that we don't break the zonefile template
  $_valid_cidr_ptr_zone = $cidr_ptr_zone.filter |$keys, $values| { $keys =~ /^[a-zA-Z0-9.\-]*$/ }
  notify { "${zone} test ${_valid_cidr_ptr_zone}":
    before => File["/var/named/zone_${cidr_ptr}"]
  }

  file{ "/var/named/zone_${cidr_ptr}":
    ensure  => present,
    owner   => root,
    group   => named,
    mode    => '0640',
    content => template('bind/ptr_cidr_zone_file.erb'),
    notify  => Exec["update_zone${cidr_ptr}"],
  }

  # This is needed to update the serial number on zone files
  exec{"update_zone${cidr_ptr}":
    refreshonly => true,
    path        => '/bin',
    command     => "sed -e \"s/serialnumber/`date +%y%m%d%H%M`/g\" /var/named/zone_${cidr_ptr} > /var/named/zone_${cidr_ptr}.db",
    notify      => Exec["zone_compile${cidr_ptr}"],
  }

  # Here the zone is compiled to verify good data
  exec{"zone_compile${cidr_ptr}":
    refreshonly => true,
    command     => "/usr/sbin/named-compilezone -o /var/named/data/zone_${cidr_ptr} ${cidr_ptr} /var/named/zone_${cidr_ptr}.db",
    notify      => Exec['zone_reload'],
  }

}
