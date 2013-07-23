require 'net/sftp'

module Interfaces

  module SftpSession
    def self.included base
      base.send :attribute, :user
      base.send :attribute, :port
      base.send :attribute, :password
      base.send :validates_presence_of, :user
    end

    def session
      logger.debug{"#{self}: about to sftp login on #{host}, user #{user}"}
      opts = {}
      opts[:port] = port if port
      opts[:password] = password if password
      Net::SSH.start(host, user, opts) do |ssh|
        # implementation before 2013-07-23
        #ssh.sftp.connect do |sftp|
        #  logger.debug{"#{self}: entering sftp session on #{host}, user #{user}"}
        #  yield sftp
        #  logger.debug{"#{self}: exiting  sftp session on #{host}, user #{user}"}
        #end
        sftp = ssh.sftp
        sftp.connect! 
        raise InterfaceError, "#{self}: sftp not open" unless sftp.open?
        logger.debug{"#{self}: entering sftp session on #{host}, user #{user}"}
        yield sftp
        logger.debug{"#{self}: exiting  sftp session on #{host}, user #{user}"}
      end
    end
  end
end

=begin
# patch since c1 does not accept default packet size of 0x10000
module Net
  module SSH
    module Connection
      OriginalChannel = Channel
      remove_const :Channel      
      class Channel < OriginalChannel
        def initialize(connection, type, local_id, &on_confirm_open)
          super
          @local_maximum_packet_size = 0x8000
        end
      end
    end
  end
end
=end
