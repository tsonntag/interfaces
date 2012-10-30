dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

module Interfaces
  VERSION = '0.0.1'

  require 'interfaces/event'
  
  autoload :Base,               'interfaces/base'
  autoload :Builder,            'interfaces/builder'
  autoload :CmdFilter,          'interfaces/cmd_filter'
  autoload :DirSink,            'interfaces/dir_sink'
  autoload :DirSource,          'interfaces/dir_source'
  autoload :Filter,             'interfaces/filter'
  autoload :FtpSession,         'interfaces/ftp_session'
  autoload :FtpSink,            'interfaces/ftp_sink'
  autoload :FtpSinkBase,        'interfaces/ftp_sink_base'
  autoload :FtpSource,          'interfaces/ftp_source'
  autoload :FtpSourceBase,      'interfaces/ftp_source_base'
  autoload :Interface,          'interfaces/interface'
  autoload :Log,                'interfaces/log'
  autoload :MailReceiver,       'interfaces/mail_receiver'
  autoload :MailSink,           'interfaces/mail_sink'
  autoload :MailSource,         'interfaces/mail_source'
  autoload :PasswordHider,      'interfaces/password_hider'
  autoload :PgpDecryptFilter,   'interfaces/pgp_decrypt_filter'
  autoload :PgpEncryptFilter,   'interfaces/pgp_encrypt_filter'
  autoload :RemoteSource,       'interfaces/remote_source'
  autoload :SftpSession,        'interfaces/sftp_session'
  autoload :SftpSink,           'interfaces/sftp_sink'
  autoload :SftpSource,         'interfaces/sftp_source'
  autoload :Sink,               'interfaces/sink'
  autoload :Source,             'interfaces/source'
  autoload :Utils ,             'interfaces/utils'
  autoload :UnzipFilter,        'interfaces/unzip_filter'
  autoload :ZipFilter,          'interfaces/zip_filter'
  autoload :ZipEncryptFilter,   'interfaces/zip_encrypt_filter'
  
end