module Interfaces

  class Event
    attr_reader :interface, :source_pathes

    def initialize( interface, source_pathes )
      @interface, @source_pathes = interface, source_pathes
    end

    def to_s
      "#{self.class}(#{interface.name},#{Utils.basenames(source_pathes)*','})"
    end
  end

  class BeforeEvent < Event
  end

  class AfterFiltersEvent < Event
  end

  class SuccessEvent < Event
    attr_reader :target_pathes, :sink_pathes

    def initialize( interface, source_pathes, target_pathes, sink_pathes )
      super interface, source_pathes
      @target_pathes, @sink_pathes = target_pathes, sink_pathes
    end
  end

  class ErrorEvent < Event
    attr_reader :msg

    def initialize( interface, source_pathes, msg )
      super interface, source_pathes
      @msg = msg
    end
  end

end
