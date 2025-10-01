require 'logger'

module Interfaces
  # Logger for permanent log files
  #
  # Logs successfully transfered filenames
  class Log < ::Logger
    def initialize *args
      super
      self.formatter = Formatter.new
      self.formatter.datetime_format = "%Y-%m-%dT%H:%M:%S"
    end

    def log name, sources, targets=nil
      s = Utils.basenames([sources].flatten).join(',')
      t = targets && Utils.basenames([targets].flatten).join(',')
      msg = if t == nil || s == t
        s
      else
        s + " => " + t
      end
      info(name){ msg }
    end
  end

  class Formatter < ::Logger::Formatter
    Format = "[%s] %s: %s\n"

    def call severity, time, progname, msg
      Format % [format_datetime(time), progname, msg2str(msg)]
    end
  end
end
