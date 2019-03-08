module Interfaces

  class GzipFilter < CmdFilter

    def target_pathes path
      "#{path}.gz"
    end

    def cmd path
      "gzip #{path}"
    end
  end
end
