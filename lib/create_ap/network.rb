require 'ipaddress'
require 'create_ap/utils'

module CreateAp
  class NetworkOptions
    attr_reader :net

    def initialize(gateway, netmask = '255.255.255.0')
      netmask ||= '255.255.255.0'
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

  class NetworkCtl
    def initialize(config)
      @config = config
      @ports = {
        tcp: [],
        udp: []
      }
    end

    def allow_tcp_port(port)
      @ports[:tcp] << port
    end

    def allow_udp_port(port)
      @ports[:udp] << port
    end

    def reload
      workaround_networkmanager
      network_reload
      firewall_reload
    end

    def network_reload
      network_reset
      @config.networks.each do |name, network|
        gateway_cidr = "#{network.gateway}/#{network.netmask}"
        br_name = "br-ap-#{name}"
        CreateAp::run("ip link add name #{br_name} type bridge")
        open("/sys/class/net/#{br_name}/bridge/forward_delay", 'w') { |f| f.puts 200 }
        CreateAp::run("ip addr add #{gateway_cidr} broadcast #{network.broadcast} dev #{br_name}")
        CreateAp::run("ip link set dev #{br_name} up")
      end
    end

    def firewall_reload
      firewall_reset
      iptables_init_chains

      @config.networks.each do |name, network|
        net_cidr = "#{network.network}/#{network.netmask}"
        br_name = "br-ap-#{name}"
        iptables_append("create_ap-postrouting -t nat -s #{net_cidr} ! -o #{br_name} -j MASQUERADE")
        iptables_append("create_ap-forward -i #{br_name} ! -o #{br_name} -j ACCEPT")
        iptables_append("create_ap-forward -i #{br_name} -o #{br_name} -j ACCEPT")
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

    def reset
      firewall_reset
      network_reset
    end

    def network_reset
      # remove ap interfaces from br-ap interfaces
      Dir.glob('/sys/class/net/ap*').each do |x|
        iface = File.basename(x)
        CreateAp::run("ip link set dev #{iface} down")
        CreateAp::run("ip link set dev #{iface} promisc off")
        CreateAp::run("ip link set dev #{iface} nomaster")
      end

      # remove br-ap interfaces
      Dir.glob('/sys/class/net/br-ap-*').each do |x|
        iface = File.basename(x)
        CreateAp::run("ip link del #{iface}")
      end
    end

    def firewall_reset
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

    def iptables_init_chains
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

    def workaround_networkmanager
      return if CreateAp::which('udevadm').empty?
      return unless Dir.exist? "#{RUN_PATH}/udev"

      FileUtils.mkpath("#{RUN_PATH}/udev/rules.d")

      open("#{RUN_PATH}/udev/rules.d/create_ap.rules", 'w') do |f|
        f.puts <<~'END'
        SUBSYSTEM!="net", GOTO="create_ap-end"
        ACTION!="add|change", GOTO="create_ap-end"

        ENV{INTERFACE}=="br-ap-*", ENV{NM_UNMANAGED}="1"
        END

        # TODO: if interface does not support virtual interfaces make it also
        # unmanaged
        @config.access_points.map{ |x| x.last.iface.ifname }.uniq.each do |iface|
          iface = iface[/([^-]+)/]
          f.puts %Q(ENV{INTERFACE}=="#{iface}-*", ENV{NM_UNMANAGED}="1")
        end

        f.puts 'LABEL="create_ap-end"'
      end

      CreateAp::run('udevadm control --reload')
      CreateAp::run('udevadm trigger -s net')
      # TODO: to make NetworkManager to set the non-virtual device to unmanage
      # we need to delete it and readd it
    end
  end
end
