class NetworkOptions
  attr_accessor :gateway, :netmask

  def initialize(gateway, netmask = '255.255.255.0')
    @gateway = gateway
    @netmask = netmask
  end
end
