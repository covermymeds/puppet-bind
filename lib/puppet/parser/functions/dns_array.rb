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

        would return {"host1.example.com" => "192.168.30.22", ...ect}

    ENDHEREDOC
    require "timeout"
    require "net/https"
    require "uri"
    require "json"
    begin
      timeout(40) do

      uri = URI.parse("#{args[0]}apiapp=#{args[1]}&apitoken=#{args[2]}&domain=#{args[3]}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.ssl_version=:TLSv1_2
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 30
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.body
      end
    end
  end
end
