require 'logger'
require 'fileutils'
require 'create_ap/hostapd'
require 'create_ap/access_point'
require 'create_ap/wifi_iface'
require 'create_ap/network'
require 'create_ap/dnsmasq'
require 'create_ap/config'

module CreateAp
  RUN_PATH =
    if Dir.exist? '/run'
      '/run'
    elsif Dir.exist? '/var/run'
      '/var/run'
    end

  TMP_DIR = "#{RUN_PATH}/create_ap"
  YAML_CONF_FILE = 'create_ap.yml'

  Log = Logger.new(STDOUT)
  Log.level = Logger::INFO
  Log.formatter = proc do |level, time, progname, msg|
    level = level == "INFO" ? '' : "#{level}: "
    "#{time.strftime '%H:%M:%S.%3N'}: #{level}#{msg}\n"
  end

  def self.main
    FileUtils.remove_dir TMP_DIR if Dir.exist? TMP_DIR
    FileUtils.mkpath TMP_DIR

    config = Config.new(YAML_CONF_FILE)
    dnsmasq = Dnsmasq.new(config)
    networkctl = NetworkCtl.new(config)
    hostapd = Hostapd.new(config)

    networkctl.allow_tcp_port(53)
    networkctl.allow_udp_port(53)
    networkctl.allow_udp_port(67)

    networkctl.reload
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
    networkctl.reset
  end
end
