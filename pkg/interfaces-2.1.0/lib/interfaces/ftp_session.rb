require 'net/ftp'

module Interfaces

  module FtpSession

    def self.included base
      base.send :attribute,:user
      base.send :attribute,:password
      base.send :validates_presence_of, :user, :password
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
