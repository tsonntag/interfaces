require '../lib/interfaces'
include Interfaces

sink = SftpSink.new host: 'dxcsy0.bn.detemobil.de', user: 'hermes', password: 'Lag1Lag', remote_dir: '.'
sink.put_files __FILE__
