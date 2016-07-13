require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts
fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.hiera_config = File.expand_path(File.join(fixture_path, 'hiera.yaml'))
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.default_facts = {
    concat_basedir: '/tmp',
    is_pe: false,
    selinux_config_mode: 'disabled',
    puppetversion: Puppet.version,
    facterversion: Facter.version,
    ipaddress: '172.16.254.254',
    macaddress: 'AA:AA:AA:AA:AA:AA'
  }
end
# vim: syntax=ruby
