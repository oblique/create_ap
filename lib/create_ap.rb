require 'fileutils'
require 'create_ap/hostapd'
require 'create_ap/access_point'
require 'create_ap/wifi_iface'
require 'create_ap/network'
require 'create_ap/dnsmasq'

CONF_DIR =
  if Dir.exist? '/run'
    '/run/create_ap'
  elsif Dir.exist? '/var/run'
    '/var/run/create_ap'
  else
    '/tmp/create_ap'
  end

FileUtils.remove_dir CONF_DIR if Dir.exist? CONF_DIR
Dir.mkdir CONF_DIR

network = NetworkOptions.new '192.168.12.1'
ap = AccessPointOptions.new 'myap', 'passphrase'
ap.iface = WifiIface.new 'wlan1'

hostapd = Hostapd.new ap.iface.phy
dnsmasq = Dnsmasq.new

hostapd.add_ap ap
dnsmasq.add_network network

# TODO: create firewall class
# enable nat
net_cidr = "#{network.network}/#{network.netmask}"
ifname = ap.iface.ifname
`iptables -w -t nat -I POSTROUTING -s #{net_cidr} ! -o #{ifname} -j MASQUERADE`
`iptables -w -I FORWARD -i #{ifname} ! -o #{ifname} -j ACCEPT`
`iptables -w -I FORWARD -i #{ifname} -o #{ifname} -j ACCEPT`
open('/proc/sys/net/ipv4/conf/all/forwarding', 'w') { |f| f.puts 1 }
open('/proc/sys/net/ipv4/ip_forward', 'w') { |f| f.puts 1 }

# set ip
`ip link set down dev #{ifname}`
`ip addr flush #{ifname}`
`ip addr add #{network.gateway}/#{network.netmask} broadcast #{network.broadcast} dev #{ifname}`

# add fw rules
`iptables -w -I INPUT -p tcp -m tcp --dport 53 -j ACCEPT`
`iptables -w -I INPUT -p udp -m udp --dport 53 -j ACCEPT`
`iptables -w -I INPUT -p udp -m udp --dport 67 -j ACCEPT`

dnsmasq.start
hostapd.start

Signal.trap('INT') { throw :exit_signaled }
Signal.trap('TERM') { throw :exit_signaled }

catch :exit_signaled do
  sleep
end

puts
puts 'Exiting...'

hostapd.stop
dnsmasq.stop

# disable nat
`iptables -w -t nat -D POSTROUTING -s #{net_cidr} ! -o #{ifname} -j MASQUERADE`
`iptables -w -D FORWARD -i #{ifname} ! -o #{ifname} -j ACCEPT`
`iptables -w -D FORWARD -i #{ifname} -o #{ifname} -j ACCEPT`
open('/proc/sys/net/ipv4/conf/all/forwarding', 'w') { |f| f.puts 0 }
open('/proc/sys/net/ipv4/ip_forward', 'w') { |f| f.puts 0 }

# unset ip
`ip link set down dev #{ifname}`
`ip addr flush #{ifname}`

# remove fw rules
`iptables -w -D INPUT -p tcp -m tcp --dport 53 -j ACCEPT`
`iptables -w -D INPUT -p udp -m udp --dport 53 -j ACCEPT`
`iptables -w -D INPUT -p udp -m udp --dport 67 -j ACCEPT`
