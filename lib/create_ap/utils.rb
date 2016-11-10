require 'create_ap/subprocess'

module CreateAp
  def self.run(*args)
    p = Subprocess.new(*args)
    status = p.each do |line|
      if block_given?
        yield line
      else
        Log.info "#{p.exe}[#{p.pid}]: #{line}"
      end
    end
    status&.success?
  end

  def self.which(cmd)
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exe = File.join(path, cmd)
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
    nil
  end

  def self.cat(file)
    open(file) { |f| f.read }
  end

  def self.mac(iface)
    cat("/sys/class/net/#{iface}/address").chop rescue nil
  end

  def self.all_mac
    macs = []
    Dir.glob('/sys/class/net/*/address') do |x|
      macs << cat(x).chop rescue next
    end
    macs
  end

  def self.iface?(ifname)
    File.exist? "/sys/class/net/#{ifname}"
  end
end
