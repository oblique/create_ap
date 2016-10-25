require 'logger'

$log = Logger.new(STDOUT)
$log.level = Logger::INFO

$log.formatter = proc do |level, time, progname, msg|
  level = level == "INFO" ? '' : "#{level}: "
  "#{time.strftime '%H:%M:%S.%3N'}: #{level}#{msg}\n"
end

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
