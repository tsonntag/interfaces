module Interfaces

  # Abstract class for sources.
  #
  # Subclasses must implement #do_get_files
  # returning an array of the pathes of the locally created files.
  #
  # Required parameters are:
  # * :dir     path of local directory
  #
  # By default files ending with .err, .old, .tmp are omitted
  class Source < Base

    attribute :dir
    validates_presence_of :dir

    def get_files regexp
      logger.debug{"#{self}: about to get files #{regexp}"}
      pathes = do_get_files regexp
      files = Utils.basenames pathes
      logger.info{"#{self}: got #{files.size} files #{files.inspect}"} if files.size > 0
      pathes
    end

    def find_file file
      get_files Regexp.escape(file)
    end

    protected

    # To be used by subclasses
    #
    # Returns array of matching pathes in dir
    def get_local_files regexp
      Dir[File.join(dir, '*')].select do |path|
        name = File.basename path
        File.file?(path) and name =~ regexp
      end
    end
  end
end
