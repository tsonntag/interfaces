require 'net/imap'
require 'timeout'

module Interfaces
  # Fetches mails with given subject from an IMAP server
  # and provides the attached files.
  #
  # Required params:
  # * :host  IMAP host
  # * :port  IMAP port (defaults to 143)
  # * :user  IMAP user
  # * :password IMAP password
  # * :subject
  class MailSource < RemoteSource
    attribute :host
    attribute :user
    attribute :password
    attribute :subject
    validates_presence_of :host, :user, :password, :subject

    def get_remote_files
      imap = nil
      logger.debug{"#{self}: about to open imap"}
      Timeout::timeout(5) { imap = Net::IMAP.new(host,port||143) } && fetch(imap)
    rescue Timeout::Error
      logger.error{"#{self}:  imap login timeout"}
      raise
    ensure
      logger.debug{"#{self}:  about to close imap #{imap}"}
      imap.close if imap
    end

    def to_s
      super.to_s + "(#{subject})"
    end

    private

    def fetch imap
      imap.authenticate('LOGIN', user, password)
      imap.select('INBOX')
      logger.debug{"#{self}: about to search subject #{subject}"}
      imap.search(["SUBJECT", subject]).each do |seq|
        #msg = imap.fetch(seq, ["BODY"]).first.attr['BODY']
        msg = fetch_attr imap, seq, "BODY"

        envelope = fetch_attr imap, seq, "ENVELOPE" 
        logger.info{"#{self}: fetching msg #{seq} from #{envelope.from.first.name}, subject: #{envelope.subject}"}

        tmpfiles = fetch_part(imap, seq, msg).flatten
        filenames = Utils.untmp_pathes tmpfiles
        logger.debug{"#{self}: fetched from msg #{seq} filenames: #{filenames.inspect} "}

        mark_done imap, seq, remote_mark_done 
      end
    end

    def fetch_part imap, seq, part, i = nil
      logger.debug{"#{self}: about to fetch part #{seq}. mulitipart=#{part.multipart?}"}
      if part.multipart?
        j = 1
        part.parts.map do |p|
          index = i ? "#{i}.#{j}" : "#{j}"
          j += 1
          fetch_part imap, seq, p, index
        end
      elsif part.media_type == "APPLICATION" || part.media_type = "TEXT"
        fetch_file imap, seq, part, i
      end
    end

    # returns tmp file
    def fetch_file imap, seq, part, i
      filename = part.param['NAME']
      logger.debug{"#{self}: checking filename #{filename}. matches?=#{matches?(filename)}"}
      return [] unless matches? filename

      data = fetch_attr imap, seq, "BODY[#{i}]"
      if part.encoding == "BASE64"
        content = data.unpack("m")
      else
        content = data
      end
      tmpfile = File.join( dir, filename + '.tmp' )
      File.open(tmpfile,'wb+'){|f| f.write content }
      logger.info{"#{self}: msg #{seq}: created file #{tmpfile}"}
      [tmpfile]
    end

    def fetch_attr imap, seq, key
      imap.fetch(seq, [key]).first.attr[key]
    end

    def mark_done imap, seq, mark_done = nil
      if mark_done
        imap.copy seq, "INBOX.processed"
        imap.store seq, "+FLAGS", [:Deleted]
        logger.debug{"#{self}: moved msg #{seq} to processed"}
      end
    end

  end
end
