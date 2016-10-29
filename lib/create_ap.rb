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
