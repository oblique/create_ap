require 'pty'

class Subprocess
  attr_reader :pid, :exe

  def initialize(*args)
    exe =
      if args.size == 1
        args[0].split[0]
      else
        args[0]
      end
    @exe = File.basename(exe)
    @r, @w, @pid = PTY.spawn(*args)
    $log.debug "[pid #{@pid}] Running: #{arr_to_cmd_str(*args)}"
  end

  def each(&block)
    enum = Enumerator.new do |yielder|
      begin
        @r.each do |line|
          yielder.yield line.chop
        end
      rescue Errno::EIO
      ensure
        Process.wait @pid
      end

      if $?.signaled?
        signame = 'SIG' << Signal.signame($?.termsig)
        $log.debug "[pid #{@pid}] Killed with #{signame}"
      else
        $log.debug "[pid #{@pid}] Exit status: #{$?.exitstatus}"
      end

      $?
    end
    enum.each(&block) if block_given?
  end

  private

  def arr_to_cmd_str(*args)
    return args[0] if args.size == 1
    cmd = ''
    args.each do |x|
      q = (x =~ /\s/ || x.empty?) ? '"' : ''
      cmd << ' ' unless cmd.empty?
      cmd << "#{q}#{x}#{q}"
    end
    cmd
  end
end

