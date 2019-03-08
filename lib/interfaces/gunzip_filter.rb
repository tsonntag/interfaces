module Interfaces

  class GunzipFilter < CmdFilter

    def available_files dir
      Dir.glob File.join(dir,'*.{gz}')
    end

    def target_pathes path
      path.gsub /\.(gz)$/, ''
    end

    def cmd path
      "gunzip -c #{path} > #{target_pathes path}"
    end
  end

end
