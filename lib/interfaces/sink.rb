module Interfaces
  # Base class for sinks.
  # Subclasses must implement #do_put_files(pathes)
  class Sink < Base
    attribute :tmp, default: '.tmp'

    # returns target_pathes
    def put_files pathes
      pathes = [pathes].flatten
      return if pathes.empty?
      logger.debug{"#{self}: about to put files #{pathes.inspect}"}
      sink_pathes = do_put_files pathes
      logger.info{"#{self}: put files #{Utils.basenames(pathes).join(',')}"}
      sink_pathes
    end
  end
end
