module CreateAp
  DNS_PORT = 5366

  class Dnsmasq
    def initialize(config)
      @config = config
      @conf = "#{TMP_DIR}/dnsmasq.conf"
      @lease_file = "#{TMP_DIR}/dhcp.leases"
      @daemon_name = "dnsmasq"
    end

    def start
      write_config
      CreateAp::daemonctl.add(@daemon_name, 'dnsmasq', '-C', @conf, '-k')
    end

    def stop
      CreateAp::daemonctl.rm(@daemon_name)
    end

    def restart
      stop rescue
      start
    end

    private

    def write_config
      open(@conf, 'w') do |f|
        f.puts <<~END
        port=#{DNS_PORT}
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
        @config.networks.each do |name, n|
          f.puts <<~END
          dhcp-range=#{name},#{n.host_min},#{n.host_max},#{n.netmask},24h
          dhcp-option-force=#{name},option:router,#{n.gateway}
          dhcp-option-force=#{name},option:dns-server,#{n.dns.join(',')}
          END
        end
      end
    end
  end
end
