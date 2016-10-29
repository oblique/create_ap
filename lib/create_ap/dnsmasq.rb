class Dnsmasq
  def initialize
    @networks = []
    @conf = "#{CONF_DIR}/dnsmasq.conf"
    @lease_file = "#{CONF_DIR}/dhcp.leases"
    @thread = nil
    @process = nil
  end

  def add_network(network)
    unless network.is_a? NetworkOptions
      raise(ArgumentError, "Invalid type, expected NetworkOptions")
    end
    @networks << network
  end

  def start
    if @process
      Log::debug 'dnsmasq is already running'
      return nil
    end

    write_config
    @process = Subprocess.new('dnsmasq', '-C', @conf, '-k')
    @thread = Thread.new do
      @process.each do |line|
        Log::info "#{@process.exe}[#{@process.pid}]: #{line}"
      end
    end
  end

  def stop
    Process.kill('TERM', @process.pid) if @process&.pid
    @thread&.join
    @thread = nil
    @process = nil
  end

  def restart
    stop
    start
  end

  private

  def write_config
    open(@conf, 'w') do |f|
      f.puts <<~END
      dhcp-authoritative
      domain-needed
      localise-queries
      bogus-priv
      expand-hosts
      local-service
      domain=lan
      server=/lan/
      dhcp-leasefile=#{@lease_file}
      END
      @networks.each_with_index do |n, idx|
        f.puts <<~END
        dhcp-range=net#{idx},#{n.host_min},#{n.host_max},#{n.netmask},24h
        dhcp-option-force=net#{idx},option:router,#{n.gateway}
        dhcp-option-force=net#{idx},option:dns-server,#{n.dns.join(',')}
        END
      end
    end
  end
end
