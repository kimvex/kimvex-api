require "logger"

class LoggerK
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.progname = "kimvex-log"

    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      label = severity.unknown? ? "ANY" : severity.to_s
      io << label[0] << ", [" << datetime << " #" << Process.pid << "] "
      io << label.rjust(5) << " -- " << progname << ": " << message
    end
  end

  def warn(text = "")
    @logger.warn(text)
  end

  def info(text = "")
    @logger.info(text)
  end
end
