module Interfaces

  class GzipFilter < CmdFilter
    attribute :gzip_cmd
    validates_presence_of :gzip_cmd

    def target_pathes path
      "#{path}.gz"
    end

    def cmd path
      # variables for eval:
      target_path = self.target_pathes path
      eval gzip_cmd
    end
  end
end
