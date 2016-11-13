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
      @virt_ifaces = []
    end

    def support_auto_channel?
      @support_auto_channel
    end

    def mac
      CreateAp::mac(@ifname)
    end

    # we create only the first virtual interface, the rest are created by hostapd
    def alloc_virt_iface
      ifname = @ifname.match(/(ap-)?([^-]+)/)[2]

      virt = nil
      1.upto(255) do |x|
        # WARNING: On Intel adapters we get `nl80211: Could not configure driver mode`
        # if we use `wlan0-1`, but we don't if we use `wlan0-0` or if we prefix
        # the name with a string. We don't know why this is happening.
        # To solve the problem, we add the `ap-` prefix.
        virt = "ap-#{ifname}-#{x}"
        break unless CreateAp::iface?(virt) || @virt_ifaces.any? { |v| v[0] == virt }
      end

      vmac = mac
      1.upto(255) do |x|
        vmac = vmac.split(':').map { |v| v.to_i(16) }
        vmac[5] = (vmac[5] + 1) % 256
        vmac = vmac.map{ |v| '%02x' % v }.join(':')
        break unless CreateAp::all_mac.count(vmac) > 0 || @virt_ifaces.any? { |v| v[1] == vmac }
      end

      if @virt_ifaces.empty?
        CreateAp::run("iw phy #{@phy} interface add #{virt} type __ap")
        # change mac address only if it's needed
        if CreateAp::mac(virt) == mac
          CreateAp::run("ip link set dev #{virt} address #{vmac}")
        end
        # get the current mac
        vmac = CreateAp::mac(virt)
      end

      @virt_ifaces << [virt, vmac]
      [virt, vmac]
    end

    def active_channels
      channels = []

      iw_dev.scan(/channel\s+(\d+)\s+.*/) do |x|
        channels << x[0].to_i
      end

      channels
    end

    private

    def iw_dev
      iwdev = `iw dev`
      phy_num = @phy.match(/phy(\d+)/)[1].to_i

      s = ''
      iwdev.each_line do |line|
        if line =~ /^phy##{phy_num}/ ... line =~ /^phy#/
          s << line unless line =~ /^phy#/
        end
      end
      s
    end

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

      # N is in both, 2.4ghz and 5ghz
      unless @ieee80211.empty?
        # if adapter has HT capabilities then it supports N
        iw_info.scan(/^\s+Capabilities: (0x\h+).*?^\s+\* (\d+) MHz \[\d+\]/m) do |x|
          cap = x[0].to_i(16)
          mhz = x[1].to_i
          band = mhz / 1000
          @ieee80211 << :n if cap != 0 && [2, 5].include?(band)
        end
      end

      if @ieee80211.include? :a
        # If adapter has VHT capabilities then it supports AC.
        iw_info.scan(/^\s+VHT Capabilities \((0x\h+)\).*?^\s+\* (\d+) MHz \[\d+\]/m) do |x|
          cap = x[0].to_i(16)
          mhz = x[1].to_i
          band = mhz / 1000
          @ieee80211 << :ac if cap != 0 && band == 5
        end
      end
    end
  end
end
