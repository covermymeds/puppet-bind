module Puppet::Parser::Functions
  newfunction(:cidr_zone, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Returns an array suitable for passing to a defined type to create zone files.
    Arguments are a base subnet and the CIDR number, example 10.1.0.0/22
    This function uses the Net::Addr gem, gem install netaddr
    We specifically ask for the address given to be split into class C subnets
    in the future it may be extended to deal with other CIDR classes.

    For example:

        args[0] = 10.1.0.0/22 which returns ["10.0.0.0/24", "10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

    ENDHEREDOC
    require "netaddr"
    begin
      NetAddr::CIDR.create("#{args[0]}").subnet(:Bits => 24)
    end
  end
end
