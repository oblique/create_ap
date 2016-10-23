require 'create_ap/subprocess'

class Hostapd
  def initialize(phy)
    @ap = []
    @phy = phy
    @threads = nil
    @process = nil
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
      $log.debug 'hostapd is already running'
      return nil
    end

    write_config
    @process = Subprocess.new('hostapd', '/tmp/hostapd.conf')
    @thread = Thread.new do
      @process.each do |line|
        $log.info "#{@process.exe}[#{@process.pid}]: #{line}"
      end
    end
  end

  def stop
    Process.kill('TERM', @process.pid) if @process
    @threadi&.join
    @thread = nil
    @process = nil
  end

  def restart
    stop
    start
  end

  private

  def write_config
    # TODO: change path
    open('/tmp/hostapd.conf', 'w') do |f|
      @ap.each do |ap|
        ieee80211, channel = resolve_auto(ap)
        f.puts "interface=#{ap.iface.ifname}"
        # TODO: add mac
        # f.puts "bssid=..."
        f.puts "ssid=#{ap.ssid}"
        f.puts "channel=#{channel}"

        # TODO: add country code
        # f.puts 'country_code=...'
        # f.puts 'ieee80211d=1'

        case ieee80211
        when :a
          f.puts 'hw_mode=a'
        when :g
          f.puts 'hw_mode=g'
        when :n
          # on auto channel (i.e. 0) prefer 5 GHz if available
          is_band_5 = channel >= 36 ||
            (channel == 0 && ap.iface.allowed_channels.find { |x| x[:mhz] / 1000 == 5 })

          f.puts <<~END
          hw_mode=#{is_band_5 ? 'a' : 'g'}
          ieee80211n=1
          wmm_enabled=1
          ht_capab=[HT40+]
          END
        when :ac
          # TODO: enable this when ieee80211d is enabled
          # f.puts 'ieee80211h=1'
          # TODO: check vht_capab
          f.puts <<~END
          hw_mode=a
          ieee80211n=1
          ieee80211ac=1
          wmm_enabled=1
          ht_capab=[HT40+]
          END
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
        # TODO: change path of ctrl_interface
        f.puts <<~END
        preamble=1
        beacon_int=100
        ctrl_interface=/tmp/hostapd_ctrl
        ctrl_interface_group=0
        driver=nl80211
        END
      end
    end
  end

  def resolve_auto(ap)
    ieee80211 =
      if ap.ieee80211 == :auto
        block = Proc.new { |x| ap.iface.ieee80211.include? x }
        if ap.channel == :auto
          [ :ac, :n, :g, :a ].find(&block)
        elsif ap.channel >= 1 && ap.channel <= 14
          [ :n, :g ].find(&block)
        else
          [ :ac, :n, :a ].find(&block)
        end
      else
        ap.ieee80211
      end

    channel =
      if ap.channel == :auto
        if ap.iface.support_auto_channel?
          0
        else
          case ieee80211
          when :a, :ac
            ap.iface.allowed_channels.find { |x| x[:mhz] / 1000 == 5 }
          when :g
            ap.iface.allowed_channels.find { |x| x[:mhz] / 1000 == 2 }
          when :n
            ap.iface.allowed_channels.find { |x| x[:mhz] / 1000 == 5 } ||
              ap.iface.allowed_channels.find { |x| x[:mhz] / 1000 == 2 }
          end
        end
      end

    if channel.is_a? Hash
      channel = channel[:channel]
    end

    [ ieee80211, channel ]
  end
end
