module Interfaces
  class ZipEncryptFilter < CmdFilter
    attribute :zip_encrypt_cmd
    validates_presence_of :zip_encrypt_cmd

    def target_pathes path
      "#{path}.zip"
    end

    def cmd path
      # variables for eval:
      target_path = self.target_pathes path
      eval zip_encrypt_cmd
    end
  end
end
