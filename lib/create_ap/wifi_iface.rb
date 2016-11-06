require 'set'

module CreateAp
  class WifiIface
    attr_reader :ifname, :phy, :allowed_channels, :ieee80211

    def initialize(ifname)
      unless File.exist? "/sys/class/net/#{ifname}/wireless"
        raise "'#{ifname}' is not a WiFi interface"
      end

      @ifname = ifname

      ieee_path = '/sys/class/ieee80211'
      @phy = Dir.foreach(ieee_path) do |x|
        next if x == '.' || x == '..'
        break x if File.exist? "#{ieee_path}/#{x}/device/net/#{@ifname}"
        break x if File.exist? "#{ieee_path}/#{x}/device/net:#{@ifname}"
      end

      unless @phy
        raise "Unable to get the physical interface of '#{ifname}'"
      end

      iw_info = `iw phy #{phy} info 2>&1`
      if !$?.success? || iw_info.empty?
        raise "Unable to get information about '#{ifname}'"
      end

      parse_iw_info(iw_info)

      @support_auto_channel = !`iw dev #{ifname} survey dump`.empty? && $?.success?
    end

    def support_auto_channel?
      @support_auto_channel
    end

    private

    def parse_iw_info(iw_info)
      parse_channels(iw_info)
      parse_ieee80211(iw_info)
    end

    def parse_channels(iw_info)
      @allowed_channels = []
      # parse frequency table
      iw_info.scan(/\* (\d+) MHz \[(\d+)\] (\(.*\))/) do |x|
        # frequencies that have 'no IR' or 'disable' can not be used for
        # transmission
        next if x[2] =~ /no IR|disable/
        ch = {
          channel:  x[1].to_i,
          mhz:      x[0].to_i
        }
        @allowed_channels << ch
      end
    end

    def parse_ieee80211(iw_info)
      @ieee80211 = Set.new
      @allowed_channels.each do |x|
        case x[:mhz] / 1000
        when 2
          @ieee80211 << :g
        when 5
          @ieee80211 << :a
        end
      end

      if @ieee80211.include? :g
        # if adapter has HT capabilities then it supports N
        iw_info.scan(/^\s+Capabilities: (0x\h+).*?^\s+\* (\d+) MHz \[\d+\]/m) do |x|
          cap = x[0].to_i(16)
          mhz = x[1].to_i
          @ieee80211 << :n if cap != 0 && mhz / 1000 == 2
        end
      end

      if @ieee80211.include? :a
        # If adapter has VHT capabilities then it supports AC.
        iw_info.scan(/^\s+VHT Capabilities \((0x\h+)\).*?^\s+\* (\d+) MHz \[\d+\]/m) do |x|
          cap = x[0].to_i(16)
          mhz = x[1].to_i
          @ieee80211 << :ac if cap != 0 && mhz / 1000 == 5
        end
      end
    end
  end
end
