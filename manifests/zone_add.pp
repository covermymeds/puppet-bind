# === Define: bind::zone_add
#
# Creates and adds zone files for the Bind server
#
# === Parameters
#
# $ttl: Time to live for the zone file
# $type: Forward or reverse zone file
# $data: Hash of hostnames and IP addresses
# $cidr CIDR subnet size, will be overridden if passed in
# $nameservers: Servers that are authoritative for this zone
#
# === Authors
#
# Doug Morris <dmorris@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds, unless otherwise noted
#
define bind::zone_add (
  $ttl          = 3600,
  $refresh      = 10800,
  $retry        = 3600,
  $expire       = 604800,
  $negresp      = 300,
  $type         = undef,
  $data         = undef,
  $cidr         = 24,
  $nameservers  = undef,
) {

  # Get type of server slave or master
  $type_data = $::bind::bind_domains[$name]['type']

  if $type_data == 'master' {
    # Check if this is a reverse zone
    if $name =~ /^(\d+).*arpa$/ {
      bind::ptr_zone { $name:
        zone     => $name,
        cidrsize => $cidr,
      }
    }
    else {
      bind::fwd_zone { $name:
        zone => $name,
      }
    }
  }

}
