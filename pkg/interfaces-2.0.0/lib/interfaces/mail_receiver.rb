require 'action_mailer'
require 'fileutils'

module Interfaces
  class MailReceiverError < StandardError; end

  # Saves mail attachments to current working directory
  class MailReceiver < ActionMailer::Base

    cattr_accessor :log
  
    def log
      @log ||= self.class.log
    end

    # Saves all attachments of _mail_ to current working directory
    def receive(mail)
      logger.info("mail_receiver"){"received mail #{mail_to_s(mail)}"} if logger
      if mail.has_attachments?
        filenames = mail.attachments.map{|attachment| save_file(mail,attachment)}
        log.log mail_to_s(mail), filenames if log
      else
        raise MailReceiverError, "no attachments in #{mail_to_s(mail)}"
      end
    end

    private
    def save_file(mail,attachment)
      filename = attachment.filename rescue attachment.original_filename # for active_support 3.* rsp 2.*
      tmp = "#{filename}.tmp"
      File.open( tmp, "w" ){ |file| file.print(attachment.read) }
      FileUtils.mv tmp, filename
      logger.info("mail_receiver"){"extracted file #{filename} #{mail_to_s(mail)}"} if logger
      filename
    end

    def mail_to_s(mail)
      "from #{mail.from.first}, subject #{mail.subject}"
    end
  end
end
