require 'zip'

module Interfaces
  class UnzipFilter < Filter

    def available_files dir 
      Dir.glob File.join(dir,'*.zip')
    end

    def do_filter_file path
      logger.debug{"#{self}: about to unzip #{path}"}
      dir = File.dirname path
      Zip::File.new(path).each do |entry|
        entry.extract File.join(dir,entry.name)
        logger.info{"#{self}: extracted #{entry.name} from zip file #{File.basename(path)}"}
      end
    end

    def target_pathes path
      dir = File.dirname path
      Zip::File.new(path).map{|entry| File.join(dir,entry.name)}
    end
  end
end
