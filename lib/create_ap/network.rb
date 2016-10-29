require 'ipaddress'

module CreateAp
  class NetworkOptions
    attr_reader :net

    def initialize(gateway, netmask = '255.255.255.0')
      @net = IPAddress.parse("#{gateway}/#{netmask}")
      @dns = nil
    end

    def gateway
      @net.address
    end

    def netmask
      @net.netmask
    end

    def network
      @net.network.address
    end

    def broadcast
      @net.broadcast.address
    end

    def host_min
      @net.first.address
    end

    def host_max
      @net.last.address
    end

    def dns
      @dns ? @dns : [gateway]
    end

    def dns=(d)
      d = [d] unless d.is_a? Array
      @dns = d
    end
  end
end
