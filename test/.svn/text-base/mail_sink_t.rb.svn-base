require '../lib/interfaces'

pathes = Dir.glob("H:/Data/hermes_data/test/*.txt")
puts pathes.inspect

s = Interfaces::MailSink.new( :port => 25,
  :from => 'hermes@mail.dcnv.detemobil.de',
  :address => 'localhost',
  :domain => 'localhost.local_domain',
  :recipients => 't.sonntag@telekom.de',
  :subject => "Test %files",
  :send_file_in_body => true,
  :body => Proc.new {|pathes| "Pathes: \n #{pathes.join("\n")}"}
)

s.put_files( pathes )
