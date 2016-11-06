module CreateAp
  class AccessPointOptions
    attr_reader :ssid, :passphrase, :channel, :ieee80211, :wpa, :network
    attr_accessor :iface, :hidden, :isolate_clients

    def initialize(ssid, passphrase = nil)
      self.ssid = ssid
      self.passphrase = passphrase
      @channel = :auto
      @ieee80211 = :auto
      @hidden = false
      @isolate_clients = false
      @wpa = [1, 2]
      @iface = nil
      @network = 'default'
    end

    def ssid=(ssid)
      if ssid.length < 1 || ssid.length > 32
        raise(ArgumentError, "Invalid SSID length: #{ssid.length} (expected 1..32)")
      end
      @ssid = ssid
    end

    def passphrase=(pass)
      if pass
        if pass.length == 64 && pass !~ /^\h+$/
          raise(ArgumentError, "Invalid PSK key")
        elsif pass.length < 8 || pass.length > 63
          raise(ArgumentError, "Invalid passphrase length: #{pass.length} (expected 8..63)")
        end
      end
      @passphrase = pass
    end

    def channel=(ch)
      ch ||= :auto
      @channel =
        if ch == :auto || ch == 'auto' || ch == 0
          :auto
        elsif ch.is_a? String && ch =~ /^\d+$/
          ch.to_i
        elsif ch.is_a? Integer
          ch
        end
      raise(ArgumentError, "Invalid channel: #{ch}") unless @channel
    end

    def ieee80211=(mode)
      mode ||= :auto
      valid_modes = %i(auto a g n ac)
      mode = mode.to_sym if mode.is_a? String
      unless valid_modes.include? mode
        raise(ArgumentError, "Invalid or unsupported 802.11 protocol: #{mode}")
      end
      @ieee80211 = mode
    end

    def wpa=(wpa)
      wpa ||= [1, 2]
      valid_versions = [1, 2]
      wpa = [wpa] unless wpa.is_a? Array
      wpa = wpa.uniq
      wpa.each do |x|
        raise(ArgumentError, "Invalid WPA version: #{x}") unless valid_versions.include? x
      end
      @wpa = wpa
    end

    def network=(network)
      @network = network || 'default'
    end
  end
end
