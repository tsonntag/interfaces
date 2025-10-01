module Interfaces
  class FtpSink < FtpSinkBase
    include FtpSession

    def put! session, local, remote
      session.put local, remote
    end

    def rename! session, from, to
      session.rename tmp, file
    end
  end   
end
