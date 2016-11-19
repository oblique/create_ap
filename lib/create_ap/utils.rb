require 'childprocess'

module CreateAp
  def self.run(*cmd)
    name = cmd[0]

    if cmd.length == 1
      name = name.split[0]
      cmd.unshift('/bin/sh', '-c')
    end

    r, w = IO.pipe
    p = ChildProcess.new(*cmd)
    p.io.stdout = w
    p.io.stderr = w
    p.start
    w.close
    Log.debug "[pid: #{p.pid}] Running: #{cmd}"

    loop do
      line = r.gets.chop rescue break
      Log.info "#{name}[#{p.pid}]: #{line}"
    end

    exit_code = p.wait
    r.close
    Log.debug "[pid: #{p.pid}] Exit code: #{exit_code}"

    exit_code == 0
  end

  def self.run_noout(*cmd)
    cmd.unshift('/bin/sh', '-c') if cmd.length == 1
    p = ChildProcess.new(*cmd)
    p.start

    Log.debug "[pid: #{p.pid}] Running: #{cmd}"
    exit_code = p.wait
    Log.debug "[pid: #{p.pid}] Exit code: #{exit_code}"

    exit_code == 0
  end

  def self.which(cmd)
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exe = File.join(path, cmd)
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
    nil
  end

  def self.create_lock_file(path)
    file = File.new(path, File::CREAT | File::EXCL | File::WRONLY) rescue nil
    file ||= File.new(path, File::WRONLY)
    return nil unless file.flock(File::LOCK_EX | File::LOCK_NB)
    file
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
