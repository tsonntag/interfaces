module Interfaces
 
  class Test
    def self.test
      interfaces = Interfaces::Builder.build do |b|
        b.ts :sftp, :dir
        #b.gd :ftp, :pgp_decypt, :dir
        #b.ts:ftp, :pgp_decrypt, :unzip, :dir
        #b.ts :dir, :zip,  :ftp, :mark_done => false, :collect => true
        #b.ts :mail, :pgp_decrypt, :dir
      end

      ts = interfaces[:ts]
      puts ts.inspect
      ts.call
    end
  end
end