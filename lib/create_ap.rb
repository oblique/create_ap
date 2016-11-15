require 'logger'
require 'fileutils'
require 'securerandom'
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

  @@file_lock = nil

  def self.check_files_and_dirs
    raise "`/run` directory does not exist." if RUN_PATH.nil?

    @@file_lock ||= CreateAp::create_lock_file("#{RUN_PATH}/create_ap.lock")
    raise "create_ap is already running" unless @@file_lock
  end

  def self.check_dependencies
    missing = []

    ['hostapd', 'dnsmasq', 'ip', 'iw', 'iptables'].each do |x|
      missing << x unless CreateAp::which(x)
    end

    unless missing.empty?
      raise "You need to install the following dependencies: #{missing.join(', ')}"
    end
  end

  def self.kill_unmanageable_childs
    # If a previous instance of the script crashed then some of its childs
    # might be alive. We search and kill all the processes that env variable
    # `create_ap_magic_hash` is set and is not equal to ours.
    ENV['create_ap_magic_hash'] = SecureRandom.hex(10)

    Dir.glob('/proc/*/environ') do |f|
      next unless f =~ %r(/proc/\d+/environ)
      pid = f.match(%r(/proc/(\d+)/environ))[1].to_i
      begin
        # read enviroment variables and get `create_ap_magic_hash`
        hash = open(f){ |x| x.read }
          .split("\0")
          .map{ |x| x.split('=', 2) }
          .assoc('create_ap_magic_hash')

        if hash && hash != ENV['create_ap_magic_hash']
          Process.kill('KILL', pid)
        end
      rescue Errno::EACCES, Errno::ESRCH, Errno::ENOENT
        # ignore
      end
    end
  end

  def self.main
    begin
      check_files_and_dirs
      check_dependencies
    rescue => error
      Log.error error
      exit 1
    end

    Signal.trap('TERM', 'IGNORE')
    Signal.trap('INT', 'IGNORE')

    kill_unmanageable_childs

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

    catch :exit_signaled do
      signal_exit = -> _ do
        Signal.trap('TERM', 'IGNORE')
        Signal.trap('INT', 'IGNORE')
        throw :exit_signaled
      end

      Signal.trap('TERM', &signal_exit)
      Signal.trap('INT', &signal_exit)
      sleep
    end

    puts
    puts 'Exiting...'

    hostapd.stop
    dnsmasq.stop
    networkctl.reset
  end
end
