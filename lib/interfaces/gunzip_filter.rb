module Interfaces

  class GUnzip < CmdFilter
    attribute :gunzip_cmd
    validates_presence_of :gunzip_cmd

    def available_files dir
      Dir.glob File.join(dir,'*.{gz}')
    end

    def target_pathes path
      path.gsub /\.(gz)$/, ''
    end

    def cmd path
      # variables for eval:
      target_path = self.target_pathes path
      eval gunzip_cmd
    end
  end

end
