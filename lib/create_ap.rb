require 'logger'
require 'fileutils'
require 'create_ap/hostapd'
require 'create_ap/access_point'
require 'create_ap/wifi_iface'
require 'create_ap/network'
require 'create_ap/dnsmasq'
require 'create_ap/firewall'

module CreateAp
  CONF_DIR =
    if Dir.exist? '/run'
      '/run/create_ap'
    elsif Dir.exist? '/var/run'
      '/var/run/create_ap'
    else
      '/tmp/create_ap'
    end

  Log = Logger.new(STDOUT)
  Log.level = Logger::INFO
  Log.formatter = proc do |level, time, progname, msg|
    level = level == "INFO" ? '' : "#{level}: "
    "#{time.strftime '%H:%M:%S.%3N'}: #{level}#{msg}\n"
  end

  def self.main
    FileUtils.remove_dir CONF_DIR if Dir.exist? CONF_DIR
    Dir.mkdir CONF_DIR

    network = NetworkOptions.new '192.168.12.1'
    ap = AccessPointOptions.new 'myap', 'passphrase'
    ap.iface = WifiIface.new 'wlan1'

    hostapd = Hostapd.new ap.iface.phy
    dnsmasq = Dnsmasq.new
    firewall = Firewall.new

    hostapd.add_ap ap
    dnsmasq.add_network network

    firewall.add_nat(network, ap.iface.ifname)
    firewall.allow_tcp_port(53)
    firewall.allow_udp_port(53)
    firewall.allow_udp_port(67)
    firewall.apply

    # set ip
    ifname = ap.iface.ifname
    `ip link set down dev #{ifname}`
    `ip addr flush #{ifname}`
    `ip addr add #{network.gateway}/#{network.netmask} broadcast #{network.broadcast} dev #{ifname}`

    dnsmasq.start
    hostapd.start

    Signal.trap('TERM') { throw :exit_signaled }
    Signal.trap('INT')  { throw :exit_signaled }

    catch :exit_signaled do
      sleep
    end

    puts
    puts 'Exiting...'

    hostapd.stop
    dnsmasq.stop

    # disable nat and remove fw rules
    firewall.reset

    # unset ip
    `ip link set down dev #{ifname}`
    `ip addr flush #{ifname}`
  end
end
