module Interfaces
  # Base class for sinks.
  # Subclasses must implement #do_put_files(pathes)
  class Sink < Base

    # returns target_pathes
    def put_files pathes, opts = {}
      pathes = [pathes].flatten
      return if pathes.empty?
      logger.debug{"#{self}: about to put files #{pathes.inspect}. opts=#{opts}"}
      sink_pathes = do_put_files pathes, opts
      logger.info{"#{self}: put files #{Utils.basenames(pathes).join(',')}, opts=#{opts}"}
      sink_pathes
    end
  end
end
