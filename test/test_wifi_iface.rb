require 'minitest/autorun'
require_relative 'mocks'

class TestWifiIface < Minitest::Test
  def test_1_parse_channels
    w = MockWifiIface.new
    w.send(:parse_channels)
    expected_result = [
      { channel: 1,  mhz: 2412 },
      { channel: 2,  mhz: 2417 },
      { channel: 3,  mhz: 2422 },
      { channel: 4,  mhz: 2427 },
      { channel: 5,  mhz: 2432 },
      { channel: 6,  mhz: 2437 },
      { channel: 7,  mhz: 2442 },
      { channel: 8,  mhz: 2447 },
      { channel: 9,  mhz: 2452 },
      { channel: 10, mhz: 2457 },
      { channel: 11, mhz: 2462 },
      { channel: 12, mhz: 2467 },
      { channel: 36, mhz: 5180 },
      { channel: 40, mhz: 5200 },
      { channel: 44, mhz: 5220 },
      { channel: 48, mhz: 5240 }
    ]
    assert_equal w.allowed_channels, expected_result
  end

  def test_2_parse_channels
    w = MockWifiIface.new
    w.iw_info = w.iw_info.gsub(/^\s+\* 5\d+ MHz .*$/, '')
    w.send(:parse_channels)
    expected_result = [
      { channel: 1,  mhz: 2412 },
      { channel: 2,  mhz: 2417 },
      { channel: 3,  mhz: 2422 },
      { channel: 4,  mhz: 2427 },
      { channel: 5,  mhz: 2432 },
      { channel: 6,  mhz: 2437 },
      { channel: 7,  mhz: 2442 },
      { channel: 8,  mhz: 2447 },
      { channel: 9,  mhz: 2452 },
      { channel: 10, mhz: 2457 },
      { channel: 11, mhz: 2462 },
      { channel: 12, mhz: 2467 }
    ]
    assert_equal w.allowed_channels, expected_result
  end

  def test_3_parse_channels
    w = MockWifiIface.new
    w.iw_info = w.iw_info.gsub(/^\s+\* 2\d+ MHz .*$/, '')
    w.send(:parse_channels)
    expected_result = [
      { channel: 36, mhz: 5180 },
      { channel: 40, mhz: 5200 },
      { channel: 44, mhz: 5220 },
      { channel: 48, mhz: 5240 }
    ]
    assert_equal w.allowed_channels, expected_result
  end

  def test_1_parse_ieee80211
    w = MockWifiIface.new
    w.send(:parse_channels)
    w.send(:parse_ieee80211)
    expected_result = [ :a, :g, :n, :ac ].to_set
    assert_equal w.ieee80211, expected_result
  end

  def test_2_parse_ieee80211
    w = MockWifiIface.new
    w.iw_info = w.iw_info.sub(/^\s+Capabilities.*$/, '')
    w.send(:parse_channels)
    w.send(:parse_ieee80211)
    expected_result = [ :a, :g, :ac ].to_set
    assert_equal w.ieee80211, expected_result
  end

  def test_3_parse_ieee80211
    w = MockWifiIface.new
    w.iw_info = w.iw_info.sub(/^\s+VHT Capabilities.*$/, '')
    w.send(:parse_channels)
    w.send(:parse_ieee80211)
    expected_result = [ :a, :g, :n ].to_set
    assert_equal w.ieee80211, expected_result
  end

  def test_4_parse_ieee80211
    w = MockWifiIface.new
    w.iw_info = w.iw_info.sub(/^\s+Capabilities.*$/, '').sub(/^\s+VHT Capabilities.*$/, '')
    w.send(:parse_channels)
    w.send(:parse_ieee80211)
    expected_result = [ :a, :g ].to_set
    assert_equal w.ieee80211, expected_result
  end

  def test_5_parse_ieee80211
    w = MockWifiIface.new
    w.iw_info = w.iw_info.gsub(/^\s+\* 5\d+ MHz .*$/, '')
    w.send(:parse_channels)
    w.send(:parse_ieee80211)
    expected_result = [ :g, :n ].to_set
    assert_equal w.ieee80211, expected_result
  end

  def test_6_parse_ieee80211
    w = MockWifiIface.new
    w.iw_info = w.iw_info.gsub(/^\s+\* 2\d+ MHz .*$/, '')
    w.send(:parse_channels)
    w.send(:parse_ieee80211)
    expected_result = [ :a, :ac ].to_set
    assert_equal w.ieee80211, expected_result
  end

  def test_parse_iw_info
    w = MockWifiIface.new
    w.send(:parse_iw_info)
    expected_channels = [
      { channel: 1,  mhz: 2412 },
      { channel: 2,  mhz: 2417 },
      { channel: 3,  mhz: 2422 },
      { channel: 4,  mhz: 2427 },
      { channel: 5,  mhz: 2432 },
      { channel: 6,  mhz: 2437 },
      { channel: 7,  mhz: 2442 },
      { channel: 8,  mhz: 2447 },
      { channel: 9,  mhz: 2452 },
      { channel: 10, mhz: 2457 },
      { channel: 11, mhz: 2462 },
      { channel: 12, mhz: 2467 },
      { channel: 36, mhz: 5180 },
      { channel: 40, mhz: 5200 },
      { channel: 44, mhz: 5220 },
      { channel: 48, mhz: 5240 }
    ]
    expected_ieee80211 = [ :a, :g, :n, :ac ].to_set

    assert_equal w.allowed_channels, expected_channels
    assert_equal w.ieee80211, expected_ieee80211
  end
end
