module Interfaces
  class PgpEncryptFilter < CmdFilter
    attribute :pgp_encrypt_cmd
    validates_presence_of :pgp_encrypt_cmd

    def target_pathes path
      "#{path}.pgp"
    end

    def cmd path
      # variables for eval:
      target_path = self.target_pathes path
      eval pgp_encrypt_cmd
    end
  end
end
