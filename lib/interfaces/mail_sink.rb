require 'action_mailer'
require 'active_support/core_ext/hash' # for slice

module Interfaces
  class MailSenderError < StandardError; end

  # Helper class used by MailSink
  class Mailer < ActionMailer::Base

    def my_message(pathes,params)
      [:address, :port, :domain].each do |key|
        Mailer.smtp_settings[key] = params.delete(key) if params.has_key?(key)
      end

      if recipients = params.delete(:recipients)
        params[:to] = recipients
      end

      params[:subject]= _parse(params.delete(:subject),pathes)

      if params.delete(:send_file_in_body)
        if pathes.size != 1
          raise MailSenderError, "#{self}: cannot send multiple files #{pathes * ","} in mail body"
        else
          params[:body] = File.read(pathes.first)
        end
      else
        # body must not be nil to prevent lookup of templates
        params[:body] = _parse(params[:body],pathes) || ''
        pathes.each do |path|
          attachments[File.basename(path)] = File.read(path)
        end
      end
      mail params
    end

    private

    def _parse(value, pathes)
      case value
      when nil
        nil
      when String
        value.gsub /\%files/, Utils.basenames(pathes).join(',')
      when Proc
        value.call pathes
      else
        raise MailSenderError, "invalid value #{value}. #{self}"
      end
    end
  end

  # Sends files in as Mail via SMTP
  #
  # Required params:
  # * :from
  # * :recipients
  # * :subject
  #
  # The following SMTP params must be unless injected into Interfaces::Mailer :
  # * :address
  # * :port
  # * :domain
  #
  # If :send_file_in_body is true the file (only one allowed in this case)
  # will be sent in body
  # otherwise given files will be sent as attachments.
  #
  # If :subject and :body are strings the substring _%files_ is replaced by the attached filesnames
  # 
  # If :subject and :body are procs the proc is called with argument _pathes_
  #
  class MailSink < Sink

    Mailer.logger = nil

    attribute :from
    attribute :recipients
    attribute :cc
    attribute :bcc
    attribute :subject
    attribute :address
    attribute :port
    attribute :domain
    attribute :send_file_in_body

    validates_presence_of :from, :recipients, :subject

    validate do |sink|
      [:address, :port, :domain].each do |key| 
        unless Mailer.smtp_settings[key] || sink.send(key)
          sink.errors.add :base, "missing #{key}"
        end
      end 
    end

    def do_put_files pathes
      # slice required. otherwise things like password_hider will cause an error
      #keys = Mailer.smtp_settings.keys + [:from,:recipients,:subject,:address,:port,:domain] 
      keys = [:from,:recipients,:subject,:address,:port,:domain,:cc,:bcc,:send_file_in_body] 
      Mailer.my_message(pathes, attributes.symbolize_keys.slice(*keys)).deliver
      []
    end

    def to_s
      super.to_s + "(#{recipients.inspect})"
    end
  end

end
