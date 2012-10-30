require 'net/ftp'
require 'interfaces/ftp_session'

module Interfaces

  module FtpSession
    def validate
      super
      validate_presence_of :host, :user, :password,:remote_dir
    end

    def session
      Net::FTP.open(host) do |ftp|
        logger.debug{"#{self}: about to ftp login on #{host}, user #{user}"}
        ftp.login user, password
        logger.debug{"#{self}: about to ftp chdir #{remote_dir}"}
        ftp.chdir remote_dir
        logger.debug{"#{self}: entering ftp session on #{host}, user #{user}"}
        yield ftp
        logger.debug{"#{self}: exiting  ftp session on #{host}, user #{user}"}
      end
    end

  end
end