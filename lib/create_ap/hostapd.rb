require 'create_ap/subprocess'

module CreateAp
  class Hostapd
    def initialize(config)
      @config = config
      @hostapd_proc = {}
    end

    def start
      remove_all_virt_ifaces

      @config.access_points.group_by{ |k, v| v.iface.phy }.each do |phy, aps|
        @hostapd_proc[phy] = HostapdProcess.new(phy)
        aps.each do |name, ap|
          @hostapd_proc[phy].add_ap(ap)
        end
      end

      @hostapd_proc.each do |k, hostapd|
        hostapd.start
      end
    end

    def stop
      @hostapd_proc.each do |k, hostapd|
        hostapd.stop
      end
      @hostapd_proc.clear
      remove_all_virt_ifaces
    end

    def restart
      stop
      start
    end

    private

    def remove_all_virt_ifaces
      # all our virtual interfaces have the following pattern: ifname-number
      # e.g. wlan0-1
      Dir.glob('/sys/class/net/*-*/wireless').each do |x|
        iface = x.split('/')[-2]
        CreateAp::run("iw dev #{iface} del > /dev/null 2>&1")
      end
    end
  end

  class HostapdProcess
    def initialize(phy)
      @ap = []
      @phy = phy
      @thread = nil
      @process = nil
      @conf = "#{TMP_DIR}/hostapd_#{@phy}.conf"
      @ctrl = "#{TMP_DIR}/hostapd"
    end

    def add_ap(ap)
      unless ap.is_a? AccessPointOptions
        raise(ArgumentError, "Invalid type, expected AccessPointOptions")
      end

      if ap.iface.phy != @phy
        raise(ArgumentError, "Invalid physical interface, expected '#{@phy}'")
      end

      @ap << ap
    end

    def start
      if @process
        Log.debug 'hostapd is already running'
        return nil
      end

      write_config
      @process = Subprocess.new('hostapd', @conf)
      @thread = Thread.new do
        @process.each do |line|
          Log.info "#{@process.exe}[#{@process.pid}]: #{line}"
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
        ieee80211, channel = resolve_auto
        Log.info "Using 802.11#{ieee80211}"
        Log.info "Using channel #{channel == 0 ? 'auto' : channel}"

        f.puts <<~END
        driver=nl80211
        ctrl_interface=#{@ctrl}
        ctrl_interface_group=0
        channel=#{channel}
        END
        # TODO: add country code
        # f.puts 'country_code=...'
        # f.puts 'ieee80211d=1'

        case ieee80211
        when :a, :ac
          f.puts 'hw_mode=a'
        when :g
          f.puts 'hw_mode=g'
        when :n
          # on auto channel (i.e. 0) prefer 5 GHz if available
          is_band_5 = channel >= 36 ||
            (channel == 0 && ap.iface.allowed_channels.find { |x| x[:mhz] / 1000 == 5 })
          f.puts "hw_mode=#{is_band_5 ? 'a' : 'g'}"
        end

        @ap.each_with_index do |ap, idx|
          iface, bssid = ap.iface.alloc_virt_iface
          bridge = "br-ap-#{ap.network}"

          f.puts
          if idx == 0
            f.puts "interface=#{iface}"
          else
            f.puts "bss=#{iface}"
          end

          f.puts <<~END
          bssid=#{bssid}
          ssid=#{ap.ssid}
          bridge=#{bridge}
          END

          if ieee80211 == :n || ieee80211 == :ac
            f.puts <<~END
            ieee80211n=1
            wmm_enabled=1
            ht_capab=[HT40+]
            END
          end

          if ieee80211 == :ac
            # TODO: enable this when ieee80211d is enabled
            # f.puts 'ieee80211h=1'
            # TODO: check vht_capab
            f.puts 'ieee80211ac=1'
          end

          if ap.passphrase
            wpa_versions = 0
            ap.wpa.each { |x| wpa_versions |= 1 << (x - 1) }
            pass_type = ap.passphrase.length == 64 ? 'psk' : 'passphrase'

            f.puts <<~END
            wpa=#{wpa_versions}
            wpa_#{pass_type}=#{ap.passphrase}
            wpa_key_mgmt=WPA-PSK
            wpa_pairwise=TKIP CCMP
            rsn_pairwise=CCMP
            END
          end

          f.puts 'ignore_broadcast_ssid=1' if ap.hidden
          f.puts 'ap_isolate=1' if ap.isolate_clients
          f.puts 'preamble=1'
        end
      end
    end

    def resolve_auto
      iface = @ap.first.iface

      # get all ieee80211 options and select the best one
      ieee80211_arr = @ap.map{ |x| x.ieee80211 }.uniq
      ieee80211 = %i(ac n g a).find{ |x| ieee80211_arr.include?(x) && iface.ieee80211.include?(x) }
      ieee80211 ||= :auto

      # get all channels and select the best one (prefer 5ghz over 2.4ghz)
      channel_arr = @ap.map{ |x| x.channel }.uniq.select{ |x| x.is_a? Integer }
      if %i(ac n a auto).include? ieee80211
        channel = channel_arr.find { |x| x >= 36 && iface.allowed_channels.include?(x) }
      end
      if %i(n g auto).include? ieee80211
        channel ||= channel_arr.find{ |x| x <= 14 && iface.allowed_channels.include?(x) }
      end
      channel ||= :auto

      ieee80211 = resolve_auto_ieee80211(ieee80211, channel)
      channel = resolve_auto_channel(ieee80211, channel)

      [ieee80211, channel]
    end

    def resolve_auto_ieee80211(ieee80211, channel)
      return ieee80211 unless ieee80211 == :auto

      iface = @ap.first.iface

      block = Proc.new { |x| iface.ieee80211.include? x }
      if channel == :auto
        %i(ac n g a).find(&block)
      elsif channel >= 1 && channel <= 14
        %i(n g).find(&block)
      else
        %i(ac n a).find(&block)
      end
    end

    def resolve_auto_channel(ieee80211, channel)
      return channel unless channel == :auto

      iface = @ap.first.iface
      return 0 if iface.support_auto_channel?

      channel =
        case ieee80211
        when :a, :ac
          iface.allowed_channels.find{ |x| x[:mhz] / 1000 == 5 }
        when :g
          iface.allowed_channels.find{ |x| x[:mhz] / 1000 == 2 }
        when :n
          iface.allowed_channels.find{ |x| x[:mhz] / 1000 == 5 } ||
            iface.allowed_channels.find{ |x| x[:mhz] / 1000 == 2 }
        end
      channel[:channel] if channel
    end
  end
end
