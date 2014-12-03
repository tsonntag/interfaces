require 'fileutils'

module Interfaces

  class FtpSource < FtpSourceBase
    include FtpSession

    def ftp_get_files ftp, regexp
      logger.debug{"#{self}: ftp nlst"}
      files = ftp.nlst.select{|name| name =~ regexp}
      logger.debug{"#{self}: ftp nlst: found files: #{files&&files.inspect}"}
      files.each do |name|
        tmp = File.join dir, "#{name}.tmp"
        logger.debug{"#{self}: ftp get: #{name} => #{tmp}"}
        ftp.get name, tmp
        case remote_mark_done
        when String
          logger.debug{"#{self}: ftp move to #{remote_mark_done}: #{name}"}
          ftp.rename name, "#{name}#{remote_mark_done}"
        when :delete
          logger.debug{"#{self}: ftp delete: #{name}"}
          ftp.delete name
        end
        Utils.untmp_pathes tmp 
      end
      files
    rescue Net::FTPPermError => e
      unless e.message == '550'
        logger.error{"#{self}: ftp error: #{e.inspect}"}
        raise
      end
    end
  end
end
