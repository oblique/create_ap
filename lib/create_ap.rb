require 'create_ap/hostapd'
require 'create_ap/access_point'
require 'create_ap/wifi_iface'

ap = AccessPointOptions.new 'myap', 'passphrase'
ap.iface = WifiIface.new 'wlan0'

hostapd = Hostapd.new ap.iface.phy
hostapd.add_ap ap

hostapd.start

Signal.trap('INT') { throw :exit_signaled }
Signal.trap('TERM') { throw :exit_signaled }

catch :exit_signaled do
  sleep
end

puts
puts 'Exiting...'
hostapd.stop
