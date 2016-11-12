require 'safe_yaml'
require 'create_ap/wifi_iface'

module CreateAp
  class Config
    attr_reader :yaml_config, :networks, :access_points

    def initialize(file)
      @file = file
      @networks = {}
      @access_points = {}
      reload
    end

    def reload
      @networks.clear
      @access_points.clear

      yaml_config = YAML.load_file(@file, :safe => true) if File.exist? @file
      if yaml_config
        yaml_config['network']&.each do |name, v|
          unless name =~ /^\w+$/
            Log.error 'Network name can only contain a-z, A-Z, 0-9, and _.'
            next
          end

          unless v.include? 'gateway'
            Log.error 'Network definition always must include gateway.'
            next
          end

          gateway = v['gateway']
          netmask = v['netmask']
          net = NetworkOptions.new(gateway, netmask)
          @networks[name] = net
        end

        ifaces = {}

        yaml_config['ap']&.each do |k, v|
          begin
            ssid = v['ssid']
            ssid ||= k
            passphrase = v['passphrase']
            ap = AccessPointOptions.new(ssid, passphrase)
            ap.channel = v['channel']
            ap.ieee80211 = v['ieee80211']
            ap.wpa = v['wpa']
            ifname = v['interface']
            unless ifaces.include? ifname
              ifaces[ifname] = WifiIface.new(ifname)
            end
            ap.iface = ifaces[ifname]
            ap.hidden = v['hidden']
            ap.isolate_clients = v['isolate_clients']
            ap.network = v['network']
            @access_points[k] = ap
          rescue => error
            Log.error(error)
            next
          end
        end
      end

      unless @networks.include? 'default'
        @networks.merge!('default' => NetworkOptions.new('192.168.12.1', '255.255.255.0'))
      end
    end
  end
end
