require 'net/sftp'

module Interfaces

  module SftpSession
    def validate
      super
      validate_presence_of :host, :user
    end

=begin
    def session
      logger.debug{"#{self}: about to sftp login on #{host}, user #{user}"}
      Net::SFTP.start(host, user, :password => password) do |sftp|
        logger.debug{"#{self}: entering sftp session on #{host}, user #{user}"}
        yield sftp
        logger.debug{"#{self}: exiting  sftp session on #{host}, user #{user}"}
      end
    end
=end

    def session
      logger.debug{"#{self}: about to sftp login on #{host}, user #{user}"}
      opts = {}
      if respond_to?(:port) && port
        opts[:port] = port 
      end
      opts[:password] = password if password
      Net::SSH.start(host, user, opts) do |ssh|
        ssh.sftp.connect do |sftp|
          logger.debug{"#{self}: entering sftp session on #{host}, user #{user}"}
          yield sftp
          logger.debug{"#{self}: exiting  sftp session on #{host}, user #{user}"}
        end
      end
    end
  end
end

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
