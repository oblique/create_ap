require 'minitest/autorun'
require_relative 'mocks'

module CreateAp
  class TestWifiIface < Minitest::Test
    def test_1_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceAuto.new
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :ac, ieee80211
      assert_equal 0, channel
    end

    def test_2_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceNoAuto.new
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :ac, ieee80211
      assert_equal 36, channel
    end

    def test_3_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceAuto.new
      ap.iface.iw_info = ap.iface.iw_info.gsub(/^\s+\* 5\d+ MHz .*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :n, ieee80211
      assert_equal 0, channel
    end

    def test_4_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceNoAuto.new
      ap.iface.iw_info = ap.iface.iw_info.gsub(/^\s+\* 5\d+ MHz .*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :n, ieee80211
      assert_equal 1, channel
    end

    def test_5_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceAuto.new
      ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :ac, ieee80211
      assert_equal 0, channel
    end

    def test_6_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceNoAuto.new
      ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :ac, ieee80211
      assert_equal 36, channel
    end

    def test_7_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceAuto.new
      ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+VHT Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :n, ieee80211
      assert_equal 0, channel
    end

    def test_8_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceNoAuto.new
      ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+VHT Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :n, ieee80211
      assert_equal 36, channel
    end

    def test_9_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceAuto.new
      ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
        .sub(/^\s+VHT Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :n, ieee80211
      assert_equal 0, channel
    end

    def test_10_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceNoAuto.new
      ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
        .sub(/^\s+VHT Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :n, ieee80211
      assert_equal 36, channel
    end

    def test_11_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceNoAuto.new
      ap.iface.iw_info = ap.iface.iw_info.gsub(/^\s+Capabilities.*$/, '')
        .sub(/^\s+VHT Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :g, ieee80211
      assert_equal 1, channel
    end

    def test_12_resolve_auto
      ap = AccessPointOptions.new 'test1234'
      ap.iface = MockWifiIfaceAuto.new
      ap.iface.iw_info = ap.iface.iw_info.gsub(/^\s+Capabilities.*$/, '')
        .sub(/^\s+VHT Capabilities.*$/, '')
      ap.iface.send(:parse_iw_info, ap.iface.iw_info)

      hostapd = HostapdProcess.new 'phy0'
      hostapd.add_ap(ap)
      ieee80211, channel = hostapd.send(:resolve_auto)
      assert_equal :g, ieee80211
      assert_equal 0, channel
    end
  end
end
