require 'interfaces/remote_source'

module Interfaces
  # Base class for ftp/sftp sources.
  #
  # Clients must implement
  # * #ftp_get_files(_session_) which gets files using some _session_
  # * #session which must yield the _session_
  #
  # Required params:
  # * :remote_dir
  #
  class FtpSourceBase < RemoteSource

    def validate
      super
      validate_presence_of :remote_dir
    end

    def get_remote_files regexp
      session do |session|
        logger.debug{"#{self}: about to *ftp get"}
        files = ftp_get_files session, regexp
        logger.debug{"#{self}: *ftp got files #{files.inspect}"}
      end
    end

    def to_s
      super.to_s + "(#{host},#{remote_dir})"
    end

  end
end