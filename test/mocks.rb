require 'create_ap/access_point'
require 'create_ap/wifi_iface'
require 'create_ap/hostapd'

class MockWifiIface < WifiIface
  attr_accessor :iw_info

  def initialize
    @iw_info = <<~'END'
      Wiphy phy0
        max # scan SSIDs: 4
        max scan IEs length: 2257 bytes
        Retry short limit: 7
        Retry long limit: 4
        Coverage class: 0 (up to 0m)
        Device supports AP-side u-APSD.
        Device supports T-DLS.
        Available Antennas: TX 0x7 RX 0x7
        Configured Antennas: TX 0x7 RX 0x7
        Supported interface modes:
           * IBSS
           * managed
           * AP
           * AP/VLAN
           * WDS
           * monitor
           * mesh point
           * P2P-client
           * P2P-GO
        Band 1:
          Capabilities: 0x11ef
            RX LDPC
            HT20/HT40
            SM Power Save disabled
            RX HT20 SGI
            RX HT40 SGI
            TX STBC
            RX STBC 1-stream
            Max AMSDU length: 3839 bytes
            DSSS/CCK HT40
          Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
          Minimum RX AMPDU time spacing: 8 usec (0x06)
          HT TX/RX MCS rate indexes supported: 0-23
          Frequencies:
            * 2412 MHz [1] (20.0 dBm)
            * 2417 MHz [2] (20.0 dBm)
            * 2422 MHz [3] (20.0 dBm)
            * 2427 MHz [4] (20.0 dBm)
            * 2432 MHz [5] (20.0 dBm)
            * 2437 MHz [6] (20.0 dBm)
            * 2442 MHz [7] (20.0 dBm)
            * 2447 MHz [8] (20.0 dBm)
            * 2452 MHz [9] (20.0 dBm)
            * 2457 MHz [10] (20.0 dBm)
            * 2462 MHz [11] (20.0 dBm)
            * 2467 MHz [12] (20.0 dBm)
            * 2472 MHz [13] (20.0 dBm) (no IR)
            * 2484 MHz [14] (disabled)
        Band 2:
          Capabilities: 0x19e3
            RX LDPC
            HT20/HT40
            Static SM Power Save
            RX HT20 SGI
            RX HT40 SGI
            TX STBC
            RX STBC 1-stream
            Max AMSDU length: 7935 bytes
            DSSS/CCK HT40
          Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
          Minimum RX AMPDU time spacing: 8 usec (0x06)
          HT TX/RX MCS rate indexes supported: 0-23
          VHT Capabilities (0x338001b2):
            Max MPDU length: 11454
            Supported Channel Width: neither 160 nor 80+80
            RX LDPC
            short GI (80 MHz)
            TX STBC
            RX antenna pattern consistency
            TX antenna pattern consistency
          VHT RX MCS set:
            1 streams: MCS 0-9
            2 streams: MCS 0-9
            3 streams: MCS 0-9
            4 streams: not supported
            5 streams: not supported
            6 streams: not supported
            7 streams: not supported
            8 streams: not supported
          VHT RX highest supported: 0 Mbps
          VHT TX MCS set:
            1 streams: MCS 0-9
            2 streams: MCS 0-9
            3 streams: MCS 0-9
            4 streams: not supported
            5 streams: not supported
            6 streams: not supported
            7 streams: not supported
            8 streams: not supported
          VHT TX highest supported: 0 Mbps
          Frequencies:
            * 5180 MHz [36] (20.0 dBm)
            * 5200 MHz [40] (20.0 dBm)
            * 5220 MHz [44] (20.0 dBm)
            * 5240 MHz [48] (20.0 dBm)
            * 5260 MHz [52] (20.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5280 MHz [56] (20.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5300 MHz [60] (20.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5320 MHz [64] (20.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5500 MHz [100] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5520 MHz [104] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5540 MHz [108] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5560 MHz [112] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5580 MHz [116] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5600 MHz [120] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5620 MHz [124] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5640 MHz [128] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5660 MHz [132] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5680 MHz [136] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5700 MHz [140] (27.0 dBm) (no IR, radar detection)
              DFS state: usable (for 235866 sec)
              DFS CAC time: 60000 ms
            * 5745 MHz [149] (disabled)
            * 5765 MHz [153] (disabled)
            * 5785 MHz [157] (disabled)
            * 5805 MHz [161] (disabled)
            * 5825 MHz [165] (disabled)
        valid interface combinations:
           * #{ managed } <= 2048, #{ AP, mesh point } <= 8, #{ P2P-client, P2P-GO } <= 1, #{ IBSS } <= 1,
             total <= 2048, #channels <= 1, STA/AP BI must match
           * #{ WDS } <= 2048,
             total <= 2048, #channels <= 1, STA/AP BI must match
           * #{ IBSS, AP, mesh point } <= 1,
             total <= 1, #channels <= 1, STA/AP BI must match, radar detect widths: { 20 MHz (no HT), 20 MHz, 40 MHz }

        HT Capability overrides:
           * MCS: ff ff ff ff ff ff ff ff ff ff
           * maximum A-MSDU length
           * supported channel width
           * short GI for 40 MHz
           * max A-MPDU length exponent
           * min MPDU start spacing
    END
    @iw_info = @iw_info.gsub('  ', "\t")
  end
end

class MockWifiIfaceAuto < MockWifiIface
  def initialize
    super
    @support_auto_channel = true
  end
end

class MockWifiIfaceNoAuto < MockWifiIface
  def initialize
    super
    @support_auto_channel = false
  end
end

class MockHostapd < Hostapd
  def initialize
    super 'test'
  end
end
