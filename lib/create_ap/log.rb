require 'logger'

module Log
  class << self
    attr_accessor :log

    def init
      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO
      @log.formatter = proc do |level, time, progname, msg|
        level = level == "INFO" ? '' : "#{level}: "
        "#{time.strftime '%H:%M:%S.%3N'}: #{level}#{msg}\n"
      end
    end

    def level=(level)
      Log::init unless @log
      @log.level = level
    end

    def unknown(*args)
      Log::init unless @log
      @log.unknown(*args)
    end

    def fatal(*args)
      Log::init unless @log
      @log.fatal(*args)
    end

    def error(*args)
      Log::init unless @log
      @log.error(*args)
    end

    def warn(*args)
      Log::init unless @log
      @log.warn(*args)
    end

    def info(*args)
      Log::init unless @log
      @log.info(*args)
    end

    def debug(*args)
      Log::init unless @log
      @log.debug(*args)
    end
  end
end
