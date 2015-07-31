# === Define: bind::ptr_zone
#
# Creates and adds reverse zone files for the Bind server
#
#
# === Authors
#
# Doug Morris <dmorris@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds, unless otherwise noted
#
define bind::ptr_zone (
  $zone     = undef,
  $cidrsize = undef,
) {

  # Check if we are working with something other than a class C subnet.
  if $cidrsize != '24' {
    $subs = inline_template('<%= @name.chomp(".in-addr.arpa").split(".").reverse.join(".").concat(".0/") %>')
    $subnum = "${subs}${cidrsize}"
    $nets = cidr_zone($subnum)
    bind::ptr_cidr_zone { $nets:
      zone => $subs,
    }
  } else {

    $ptr_zone = inline_template('<%= @name.chomp(".in-addr.arpa").split(".").reverse.join(".").concat(".0")  %>')
    $add_ptr_zone = parsejson(dns_array($::bind::data_src, $::bind::data_name, $::bind::data_key, $ptr_zone))

    file{ "/var/named/zone_${name}":
      ensure  => present,
      owner   => root,
      group   => named,
      mode    => '0640',
      content => template('bind/ptr_zone_file.erb'),
      notify  => Exec["update_zone${name}"],
    }

    # This is needed to update the serial number on zone files
    exec{"update_zone${name}":
      refreshonly => true,
      path        => '/bin',
      command     => "sed -e \"s/serialnumber/`date +%y%m%d%H%M`/g\" /var/named/zone_${name} > /var/named/zone_${name}.db",
      notify      => Exec["zone_compile${name}"],
    }

    # Here the zone is compiled to verify good data
    exec{"zone_compile${name}":
      refreshonly => true,
      command     => "/usr/sbin/named-compilezone -o /var/named/data/zone_${name} ${name} /var/named/zone_${name}.db",
      notify      => Exec['zone_reload'],
    }
  }
}
