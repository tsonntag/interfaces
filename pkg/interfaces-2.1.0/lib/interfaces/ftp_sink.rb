require 'interfaces/ftp_sink_base'
require 'interfaces/ftp_session'

module Interfaces
  class FtpSink < FtpSinkBase
    include FtpSession

    def ftp_put ftp, pathes
      files = pathes.map do |path| 
        file = File.basename(path)
        [path, file, "#{file}.tmp" ]
      end

      files.each do |path,file,tmp|
        logger.debug{"#{self}: ftp put #{path} => #{tmp}"}
        ftp.put path, tmp
      end

      files.each do |path,file,tmp|
        logger.debug{"#{self}: ftp rename #{tmp} => #{file}"}
        ftp.rename tmp, file
      end
    end

  end   
end
