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

    attribute :remote_mark_tmp, default: '.tmp'

    validate do |ftp_sink| 
      mark_tmp = ftp_sink.remote_mark_tmp
      unless (String === mark_tmp && !mark_tmp.empty?) || false == mark_tmp || nil == mark_tmp
        ftp_sink.errors.add :base, "invalid remote_mark_tmp #{mark_tmp}"
      end
    end

    def do_put_files pathes
      session do |session|
        if remote_mark_tmp && !remote_mark_tmp.empty?
          files = pathes.map do |path| 
            remote_path = File.join remote_dir, File.basename(path)
            [path, remote_path, "#{remote_path}#{remote_mark_tmp}" ] 
          end

          files.each do |path,remote_path,remote_tmp_path|
            logger.debug{"#{self}: ftp put #{path} => #{remote_tmp_path}"}
	    put! session, path, remote_tmp_path
          end

          files.each do |path,remote_path,remote_tmp_path|
            logger.debug{"#{self}: ftp rename #{remote_tmp_path} => #{remote_path}"}
            rename! session,  remote_tmp_path, remote_path
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
