require 'interfaces/cmd_filter'

module Interfaces

  class PgpDecryptFilter < CmdFilter

    def validate
      super
      validate_presence_of :pgp_decrypt_cmd
      cmd('test') rescue raise ArgumentError "#{self}: invalid #{pgp_decrypt_cmd}"
    end
    
    def available_files(dir)
      Dir.glob File.join(dir,'*.{pgp,asc,gpg}')
    end

    def target_pathes(path)
      path.gsub /\.(pgp|asc|gpg)$/, ''
    end

    def cmd(path)
      # variables for eval:
      target_path = self.target_pathes path
      eval pgp_decrypt_cmd
    end
  end

end
