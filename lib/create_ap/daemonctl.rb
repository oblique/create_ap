require 'childprocess'
require 'securerandom'
require 'io/wait'
require 'monitor'

module CreateAp
  class DaemonCtl

    def initialize
      @daemons = {}
      @watchdog = nil
      @lock = Monitor.new
      @magic_hash = SecureRandom.hex(10)
      start_watchdog
    end

    # If a previous instance of the script crashed then some of its childs
    # might be alive. We search and kill all the processes that env variable
    # `create_ap_magic_hash` is set and is not equal to @magic_hash.
    def kill_unmanageable
      Dir.glob('/proc/*/environ') do |f|
        next unless f =~ %r(/proc/\d+/environ)
        pid = f.match(%r(/proc/(\d+)/environ))[1].to_i
        begin
          # read enviroment variables and get `create_ap_magic_hash`
          hash = open(f){ |x| x.read }
            .split("\0")
            .map{ |x| x.split('=', 2) }
            .assoc('create_ap_magic_hash')

          if hash && hash != @magic_hash
            Process.kill('KILL', pid)
          end
        rescue Errno::EACCES, Errno::ESRCH, Errno::ENOENT
          # ignore
        end
      end
    end

    def add(name, *cmd)
      @lock.synchronize do
        raise "'Daemon #{name}' is already added" if exist? name
        @daemons[name] = { cmd: cmd, start_tm: [] }
        start_daemon(name)
      end
    end

    def rm(name)
      @lock.synchronize do
        raise "Daemon '#{name}' does not exist" unless exist? name
        @daemons[name][:proc]&.stop
        @daemons.delete(name)
      end
    end

    def rm_all
      @lock.synchronize do
        @daemons.each { |_, d| d[:proc]&.stop }
        @daemons.clear
      end
    end

    def exist?(name)
      @lock.synchronize do
        @daemons.key? name
      end
    end

    private

    def start_daemon(name)
      @lock.synchronize do
        cmd = @daemons[name][:cmd]
        r, w = IO.pipe

        p = ChildProcess.new(*cmd)
        p.io.stdout = w
        p.io.stderr = w
        p.environment['create_ap_magic_hash'] = @magic_hash
        p.cwd = '/'
        p.start
        w.close

        Thread.new do
          loop do
            line = r.gets.chop rescue break
            Log.info "#{name}: #{line}"
          end
          r.close
        end

        @daemons[name][:proc] = p
        @daemons[name][:start_tm] << Time.new
      end
    end

    def start_watchdog
      Thread.new do
        loop do
          @lock.synchronize do
            @daemons.each do |name, daemon|
              next unless daemon[:proc]
              next unless daemon[:proc].exited?
              daemon.delete(:proc)

              # if the daemon exited 3 times within 60 seconds then we disable it
              daemon[:start_tm] = daemon[:start_tm].last(3)
              if daemon[:start_tm].length == 3 && Time.new - daemon[:start_tm][0] <= 60
                Log.error "Daemon '#{name}' exited too may times too quickly. Stop retrying."
                next
              end

              Log.warn "Daemon '#{name}' exited. Try to start it again."
              start_daemon(name)
            end
          end
          sleep 2
        end
      end
    end
  end
end
