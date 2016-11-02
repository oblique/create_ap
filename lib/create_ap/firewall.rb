require 'create_ap/utils'

module CreateAp
  class Firewall
    def initialize
      @nat = []
      @ports = {
        tcp: [],
        udp: []
      }
    end

    def add_nat(network, ifname)
      unless network.is_a? NetworkOptions
        raise(ArgumentError, "Invalid type, expected NetworkOptions")
      end
      @nat << [network, ifname]
    end

    def allow_tcp_port(port)
      @ports[:tcp] << port
    end

    def allow_udp_port(port)
      @ports[:udp] << port
    end

    def apply
      reset
      init_chains

      @nat.each do |network, ifname|
        net_cidr = "#{network.network}/#{network.netmask}"
        iptables_append("create_ap-postrouting -t nat -s #{net_cidr} ! -o #{ifname} -j MASQUERADE")
        iptables_append("create_ap-forward -i #{ifname} ! -o #{ifname} -j ACCEPT")
        iptables_append("create_ap-forward -i #{ifname} -o #{ifname} -j ACCEPT")
      end

      open('/proc/sys/net/ipv4/conf/all/forwarding', 'w') { |f| f.puts 1 }
      open('/proc/sys/net/ipv4/ip_forward', 'w') { |f| f.puts 1 }

      @ports[:tcp].each do |port|
        iptables_append("create_ap-input -p tcp -m tcp --dport #{port} -j ACCEPT")
      end

      @ports[:udp].each do |port|
        iptables_append("create_ap-input -p udp -m udp --dport #{port} -j ACCEPT")
      end
    end

    def init_chains
      ['POSTROUTING'].each do |x|
        chain = "create_ap-#{x.downcase}"
        iptables("-N #{chain} -t nat")
        iptables_insert("#{x} -t nat -j #{chain}")
      end

      ['FORWARD', 'INPUT'].each do |x|
        chain = "create_ap-#{x.downcase}"
        iptables("-N #{chain}")
        iptables_insert("#{x} -j #{chain}")
      end
    end

    def reset
      ['POSTROUTING'].each do |x|
        chain = "create_ap-#{x.downcase}"
        iptables_delete("#{x} -t nat -j #{chain}")
        iptables("-t nat -F #{chain} > /dev/null 2>&1")
        iptables("-t nat -X #{chain} > /dev/null 2>&1")
      end

      ['FORWARD', 'INPUT'].each do |x|
        chain = "create_ap-#{x.downcase}"
        iptables_delete("#{x} -j #{chain}")
        iptables("-F #{chain} > /dev/null 2>&1")
        iptables("-X #{chain} > /dev/null 2>&1")
      end
    end

    private

    def iptables(rule)
      CreateAp::run("iptables -w #{rule}")
    end

    def iptables_insert(rule)
      iptables("-I #{rule}") unless iptables("-C #{rule} > /dev/null 2>&1")
    end

    def iptables_append(rule)
      iptables("-A #{rule}") unless iptables("-C #{rule} > /dev/null 2>&1")
    end

    def iptables_delete(rule)
      while iptables("-C #{rule} > /dev/null 2>&1")
        iptables("-D #{rule}")
      end
    end
  end
end
