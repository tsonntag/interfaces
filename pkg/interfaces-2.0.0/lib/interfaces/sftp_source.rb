require 'interfaces/sftp_session'
require 'interfaces/ftp_source_base'
require 'interfaces/utils'

module Interfaces

  class SftpSource < FtpSourceBase
    include SftpSession

    def ftp_get_files sftp, regexp
      require 'ruby-debug'
      debugger

      logger.debug{"#{self}: sftp: about to list entries in #{remote_dir}"}
      files = []
      sftp.dir.entries(remote_dir).each do |entry|
        filename = entry.name
        if entry.file? && filename =~ regexp
          remote_path = File.join remote_dir, filename
          tmp = File.join( dir, filename + '.tmp' )
          files << [ filename, remote_path, tmp ]
        end
      end

      files.map do |filename, remote_path, tmp|
        logger.debug{"#{self}: sftp get: #{filename} => #{tmp}"}
        sftp.download! remote_path, tmp 
        if mark_done?
          logger.debug{"#{self}: sftp move to old: #{filename}"}
          sftp.rename remote_path, "#{remote_path}.old"
        end
        Utils.untmp_pathes tmp
        filename
      end
    end
  end
end
