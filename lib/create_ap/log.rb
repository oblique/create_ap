require 'logger'

module Log
  class << self
    attr_accessor :log

    def <<(msg)
      @log << msg
    end

    def level=(level)
      @log.level = level
    end

    def unknown(*args)
      @log.unknown(*args)
    end

    def fatal(*args)
      @log.fatal(*args)
    end

    def error(*args)
      @log.error(*args)
    end

    def warn(*args)
      @log.warn(*args)
    end

    def info(*args)
      @log.info(*args)
    end

    def debug(*args)
      @log.debug(*args)
    end
  end
end

Log.log = Logger.new(STDOUT)
Log.level = Logger::INFO
Log.log.formatter = proc do |level, time, progname, msg|
  level = level == "INFO" ? '' : "#{level}: "
  "#{time.strftime '%H:%M:%S.%3N'}: #{level}#{msg}\n"
end
