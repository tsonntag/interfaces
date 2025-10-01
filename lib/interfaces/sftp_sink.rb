module Interfaces
  class SftpSink < FtpSinkBase
    include SftpSession

    def put! session, local, remote
      session.upload! local, remote
    end

    def rename! session, from, to
      session.rename! from, to
    end
  end
end
