Bind
=====

### Overview ###

This module installs and manages the bind package.  The module is designed to get all of its configuration variables from hiera.  The zone data is pulled from an external source that returns JSON arrays and hiera.  The external source needs to be a REST-like service that takes the arguments appname, apptoken, and domain.  An example of a data source is [phpIPAM-api.](https://github.com/covermymeds/phpIPAM-api)

### NOTE ###

Support for reverse lookup zones on subnets larger than CIDR /24 requires ruby gem [netaddr.](https://rubygems.org/gems/netaddr/versions/1.5.0)

#### bind: ####
Installs the named service. The module currently defaults to using a chroot environment.  Defined types are called from this manifest to write the configuration file and zone data files.

Zones are added to a name server by defining them in the host YAML file as shown below.

```
bind::domains:
  winbox.local:
    type: slave
       master:
         - 192.168.88.3
       slave:
         - 192.168.88.5
  example.com:
    type: master
      slave:
         - 192.168.88.5
```

To add domain records, add the data to hiera under the domain it belongs to.  The same form applies for adding CNAME records to a given domain, as shown below.  MX and other record types will follow in the future.

```
....
bind::zones:
  example.com:
    ttl: 3600
    nameservers:
      - ns1.example.com
      - ns2.example.com
    data:
      foo: 192.168.135.5
      sally: 192.168.135.6
      dingbat: small-bird.local.
```


#### bind::services ####
Controls the main named service and handles restarts when zone files change.

#### bind::fwd_zone ####
This defined type creates any forward lookup zones for bind. The data for the zone files will be a combination of hieradata and external data from some source.  This defined type will also write the serial number for the zone file and call ```named-compilezone``` to insure there are server stopping errors.

#### bind::ptr_zone ####
This defined type will create a reverse lookup zone using the external data source.  If you happen to have zones that are not CIDR /24, this defined type calls another defined type to handle those zones.  For the time being only CIDR subnets larger than /24 are supported.

### Subdomains ###
You can now add a subdomain that points to a name server by adding a hiera record that begins with 'SUBDOM[number]_[subdomain]: [name server]'.
```
SUBDOM1_us: ns1.us.northamerica.com
```
The above will add a record in the domain of 
```
us IN NS ns1.us.northamerica.com.
```
