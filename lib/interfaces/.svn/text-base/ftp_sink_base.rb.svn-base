require 'interfaces/sink'

module Interfaces
  # Base class for ftp sinks
  #
  # Clients must implement:
  # 
  # #ftp_put(_session_, _pathes_) which processes the _pathes_ using some _session_
  # #session which must yield the _session_
  #
  class FtpSinkBase < Sink

    def do_put_files pathes
      session do |session|
        ftp_put session, pathes
      end
      []
    end

    def to_s
      super.to_s + "(#{host},#{remote_dir})"
    end

  end
end
