require 'active_support/core_ext/hash'

module Interfaces

  class DirSink < Sink
    attribute :dir
    validates_presence_of :dir
    attribute :chmod

    # returns target_pathes
    def do_put_files pathes
      Utils.tmped_copy pathes, dir, attributes.slice('chmod')
    end

    def to_s
      super.to_s + "(#{dir})"
    end
  end

end
