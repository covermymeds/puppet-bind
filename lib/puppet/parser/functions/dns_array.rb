module Puppet::Parser::Functions
  newfunction(:dns_array, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Returns a json array of hostnames and addresses from the data source.
    Arguments are the data source, the name of the api we are using,
    the token to connect to that api, and the domain to get the IPs from. When pulling
    for a reverse lookup zone, we submit a subnet that is understood by phpipam
    and it returns all entries in that subnet.

    For example:

        args[0] = https://ipam.dev/api/GetIPs.php?
        args[1] = ipinfo
        args[2] = asdlgadOuaaeiaoewr234679ds
        args[3] = covermymeds.com 
        args[4] = true (if set to false, stubs out a fake ipam response)

        would return {"host1.example.com" => "192.168.30.22", ...ect}

    ENDHEREDOC
    require "timeout"
    require "net/https"
    require "uri"
    require "json"
    begin
      api_uri = args[0]
      api_app = args[1]
      api_token = args[2]
      api_domain = args[3]
      use_ipam = args[4]
      if use_ipam != false
        timeout(40) do

          uri = URI.parse("#{api_uri}apiapp=#{api_app}&apitoken=#{api_token}&domain=#{api_domain}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.ssl_version=:TLSv1_2
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = 30
          request = Net::HTTP::Get.new(uri.request_uri)
          response = http.request(request)
          response.body
        end
      else
        if api_domain =~ /(\d+).*/
          domain = "fake.zone"
        else
          domain = api_domain
        end
        # stub out a fake ipam response
        {
          "node1.#{domain}" => "172.16.0.1",
          "node2.#{domain}" => "172.16.0.2",
          "node3.#{domain}" => "172.16.0.3",
          "node4.#{domain}" => "172.16.0.4",
          "node5.#{domain}" => "172.16.0.5",
          "node6.#{domain}" => "172.16.0.6",
          "node7.#{domain}" => "172.16.0.7",
          "node8.#{domain}" => "172.16.0.8",
          "node9.#{domain}" => "172.16.0.9",
          "node10.#{domain}" => "172.16.0.10",
          "node11.#{domain}" => "172.16.0.11",
          "node12.#{domain}" => "172.16.0.12",
          "node13.#{domain}" => "172.16.0.13",
          "node14.#{domain}" => "172.16.0.14",
          "node15.#{domain}" => "172.16.0.15",
          "node16.#{domain}" => "172.16.0.16",
          "node17.#{domain}" => "172.16.0.17",
          "node18.#{domain}" => "172.16.0.18",
          "node19.#{domain}" => "172.16.0.19",
          "node20.#{domain}" => "172.16.0.20",
          "node21.#{domain}" => "172.16.0.21",
          "node22.#{domain}" => "172.16.0.22",
          "node23.#{domain}" => "172.16.0.23",
          `hostname`.chomp   => "172.16.0.24",
        }.to_json
      end
    end
  end
end
