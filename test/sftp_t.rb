require_relative '../lib/interfaces'
include Interfaces

sink = FtpSink.new host: 'dxcsy0.bn.detemobil.de', user: 'hermes', password: 'Lag1Lag', remote_dir: '.', tmp: false 
sink.put_files __FILE__
