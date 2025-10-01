module Interfaces
  # Base class for filters.
  #
  # To implement collect path behaviour overwrite #do_filter_files(pathes)
  #
  # To implement single path behaviour subclasses must
  # either implement #do_filter_file(path) and #target_pathes(path)
  # or overwrite #filter_file if the target_path cannot be derived from path (e.g. unzip)
  #
  class FilterError < StandardError; end
  class Filter < Base

    # returns the target pathes
    def filter_files pathes
      pathes = [pathes].flatten
      return [] if pathes.empty?
      logger.debug{"#{self}: about to filter #{pathes.inspect}"}
      targets = do_filter_files pathes

      errors = targets.select{|target| !File.exist?(target)}
      unless errors.empty?
        raise FilterError, "#{self} failed for #{pathes.inspect}: targets #{errors.inspect} do not exist."
      end
      
      logger.info{"#{self}: filtered files #{Utils.basenames(pathes).inspect} => #{Utils.basenames(targets).inspect}"}
      targets
    end

    protected
    def do_filter_files pathes
      pathes.map{|path|filter_file(path)}.flatten
    end

    def target_pathes pathes
      pathes
    end

    # returns the processed pathes
    def filter_file path
      targets = target_pathes path
      do_filter_file path
      targets
    end
  end

end
