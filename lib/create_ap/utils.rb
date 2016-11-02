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
end
