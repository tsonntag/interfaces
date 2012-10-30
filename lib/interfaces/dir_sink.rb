require 'interfaces/sink'
require 'interfaces/utils'

module Interfaces

  class DirSink < Sink

    def validate
      super
      validate_presence_of :dir
    end

    # returns target_pathes
    def do_put_files(pathes)
      Utils.tmped_copy( pathes, dir )
    end

    def to_s
      super.to_s + "(#{dir})"
    end

  end

end