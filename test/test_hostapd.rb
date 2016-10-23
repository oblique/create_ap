require 'minitest/autorun'
require_relative 'mocks'

class TestWifiIface < Minitest::Test
  def test_1_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceAuto.new
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :ac
    assert_equal channel, 0
  end

  def test_2_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceNoAuto.new
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :ac
    assert_equal channel, 36
  end

  def test_3_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceAuto.new
    ap.iface.iw_info = ap.iface.iw_info.gsub(/^\s+\* 5\d+ MHz .*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :n
    assert_equal channel, 0
  end

  def test_4_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceNoAuto.new
    ap.iface.iw_info = ap.iface.iw_info.gsub(/^\s+\* 5\d+ MHz .*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :n
    assert_equal channel, 1
  end

  def test_5_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceAuto.new
    ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :ac
    assert_equal channel, 0
  end

  def test_6_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceNoAuto.new
    ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :ac
    assert_equal channel, 36
  end

  def test_7_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceAuto.new
    ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+VHT Capabilities.*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :n
    assert_equal channel, 0
  end

  def test_8_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceNoAuto.new
    ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+VHT Capabilities.*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :n
    assert_equal channel, 36
  end

  def test_9_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceAuto.new
    ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
      .sub(/^\s+VHT Capabilities.*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :g
    assert_equal channel, 0
  end

  def test_10_resolve_auto
    ap = AccessPointOptions.new 'test1234'
    ap.iface = MockWifiIfaceNoAuto.new
    ap.iface.iw_info = ap.iface.iw_info.sub(/^\s+Capabilities.*$/, '')
      .sub(/^\s+VHT Capabilities.*$/, '')
    ap.iface.send(:parse_iw_info)

    hostapd = MockHostapd.new
    ieee80211, channel = hostapd.send(:resolve_auto, ap)
    assert_equal ieee80211, :g
    assert_equal channel, 1
  end
end
