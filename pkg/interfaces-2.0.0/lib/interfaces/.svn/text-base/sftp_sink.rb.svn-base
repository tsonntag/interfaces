require 'interfaces/ftp_sink_base'
require 'interfaces/sftp_session'

module Interfaces
  class SftpSink < FtpSinkBase
    include SftpSession

   def ftp_put sftp, pathes
      files = pathes.map do |path| 
        remote_path = File.join remote_dir, File.basename(path)
        [path, remote_path, "#{remote_path}.tmp" ] 
      end

      files.each do |path,remote_path,remote_tmp|
        logger.debug{"#{self}: ftp put #{path} => #{remote_tmp}"}
        sftp.upload! path, remote_tmp
      end

      files.each do |path,remote_path,remote_tmp|
        logger.debug{"#{self}: ftp rename #{remote_tmp} => #{remote_path}"}
        sftp.rename remote_tmp, remote_path
      end
    end

  end
end
