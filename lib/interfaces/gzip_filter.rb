module Interfaces

  class GzipFilter < CmdFilter

    def target_pathes path
      "#{path}.gz"
    end

    def cmd path
      "gzip -c #{path} > #{target_pathes path}"
    end
  end
end
