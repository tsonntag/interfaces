require 'interfaces/cmd_filter'

module Interfaces
  class ZipEncryptFilter < CmdFilter

    def validate
      super
      validate_presence_of(:zip_encrypt_cmd)
      cmd('test') rescue raise ArgumentError "#{self}: invalid #{zip_encrypt_cmd}"
    end

    def target_pathes(path)
      "#{path}.zip"
    end

    def cmd(path)
      # variables for eval:
      target_path = self.target_pathes path
      eval zip_encrypt_cmd
    end
  end
end
