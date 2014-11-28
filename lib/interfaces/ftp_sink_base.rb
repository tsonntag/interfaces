module Interfaces
  # Base class for ftp sinks
  #
  # Clients must implement:
  # 
  # #ftp_put(_session_, _pathes_) which processes the _pathes_ using some _session_
  # #session which must yield the _session_
  #
  class FtpSinkBase < Sink
    attribute :host
    attribute :remote_dir
    validates_presence_of :remote_dir, :host

    attribute :tmp, default: '.tmp'

    def do_put_files pathes
      session do |session|
        if tmp && !tmp.empty?
          files = pathes.map do |path| 
            remote_path = File.join remote_dir, File.basename(path)
            [path, remote_path, "#{remote_path}#{tmp}" ] 
          end

          files.each do |path,remote_path,remote_tmp|
            logger.debug{"#{self}: ftp put #{path} => #{remote_tmp}"}
	    put! session, path, remote_tmp
          end

          files.each do |path,remote_path,remote_tmp|
            logger.debug{"#{self}: ftp rename #{remote_tmp} => #{remote_path}"}
            rename! session,  remote_tmp, remote_path
          end 
        else
          pathes.each do |path|
            remote_path = File.join remote_dir, File.basename(path)
            logger.debug{"#{self}: ftp put #{path} => #{remote_path}"}
            put! session,  path, remote_path
	  end
	end
      end
      []
    end
 
    def to_s
      super.to_s + "(#{host},#{remote_dir})"
    end

  end
end
