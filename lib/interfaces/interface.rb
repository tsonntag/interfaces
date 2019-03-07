require 'interfaces/mktmpdir'
require 'timeout'
require 'logger'
require 'observer'

module Interfaces

  class InterfaceError < StandardError; end
  
  # An interface is a chain of _source_, _filters_, _sink_.
  #
  # #call gets files from the _source_, filters them through the _filters_ and puts the results to _sink_
  #
  # Includes Observable
  #
  # Notifies observable with arguments:
  # * _method_ :error or :success
  # * _name_   name of the this interface
  # * _pathes_ local pathes affected
  # * _msg_    an error message in case of :error
  #
  class Interface
    include Observable

    # for default logger
    cattr_accessor :logger
    self.logger = Logger.new STDOUT

    attr_reader :name, :source, :filters, :sink, :regexp, :log, :log_file, :logger
    attr_reader :retries, :retry_delay, :timeout_secs
    attr_reader :auto, :collect, :mark_done

    # Creates and interface with given _name_ from _source_, _filters_ and _sink_
    #
    # Options:
    #    :collect
    #        number of files to be transfered in one step
    #        default is 1
    #        :all means all
    #    :auto
    #        default is false
    #        if true the filters must implement #availabe_files
    #        and are applied to the files in any order until they cannot be processed anymore.
    #        Useful for filters which 'unpack' stuff (like decrypt, unzip etc.)
    #    :mark_done:
    #        suffix:  move files in source to suffix 
    #        :delete: delete files in source
    #        else:    do nothing
    #        default is '.old' 
    #    :logger
    #        general logger (for debug, error etc.)
    #    :log_file
    #        log_file for logging successfully processed files
    #    :retries
    #        default is 3
    #        if #process fails it retry :retries times before raising an exception
    #    :retry_delay
    #        default is 1
    #        seconds to sleep before next retry
    #    :timeout_secs
    #        default is nil
    #        time in secs after which a timeout is raised during
    #        source.get_files and for each call of process(pathes)
    def initialize name, source, filters, sink, regexp, options = {}
      options = options.dup
      @name = name
      @mark_done = options.delete(:mark_done){'.old'}
      Utils.validate_mark_done @mark_done 
      @collect = options.delete(:collect){1}
      @auto = options.delete(:auto){false}
      @retries = options.delete(:retries){3}
      @retry_delay = options.delete(:retry_delay){1}
      @timeout_secs = options.delete(:timeout_secs)
      @regexp = regexp
      init_loggers name, options # must be before procs
      init_procs source, filters, sink
      raise InterfaceError, "#{self}. invalid options #{options.inspect}" unless options.empty?
    end

    def call
      logger.debug{"entering call. collect=#{collect}"}
      with_retry do
        pathes = []
        with_timeout("getting files from #{source}") do
          pathes = source.get_files regexp
        end
        
        if collect == :all
          process pathes
        else
          pathes.each_slice(collect){|pathes| process pathes}
        end
      end
    end

    def to_s
      "Interface(#{name},#{source},#{sink},[#{filters.map{|f|f.to_s}.join(',')}],#{log_file}})"
    end

    private
    # if pathes are given they will be moved to .err on error
    def with_retry pathes=[]
      files = Utils.basenames pathes
      i_retry = 0
      begin
        logger.debug{"with_retry #{i_retry} of #{retries} with delay #{retry_delay}secs for files #{files.inspect}"}
        yield
      rescue Exception => e
        if i_retry < retries
          i_retry += 1
          logger.error{"#{files.inspect} failed: #{Utils.exception_to_s(e)}"}
          logger.info{"retry #{i_retry} of #{retries} with delay #{retry_delay}secs for files #{files.inspect}"}
          sleep retry_delay if retry_delay
          retry
        else
          error! e, pathes
        end
      end
    end

    def with_timeout what
      logger.debug{"entering with_timeout #{what}. timeout_secs=#{timeout_secs}"}
      Timeout.timeout(timeout_secs){yield}
    rescue Timeout::Error
      raise Timeout::Error, "expired: #{what}"
    end

    def init_procs source, filters, sink
      @source, @filters, @sink = source, filters, sink
      raise ArgumentError, "#{self}: invalid source #{@source}" unless @source.respond_to? :get_files
      raise ArgumentError, "#{self}: invalid sink #{@sink}" unless @sink.respond_to? :put_files
      @filters.each do |filter|
        raise ArgumentError, "#{self}: invalid filter #{filter}" unless filter.respond_to? :filter_files
      end
      if @auto && !@filters.all?{|f|f.respond_to? :available_files}
        raise ArgumentError, "#{self}. auto is true, but not supported by all filters"
      end
      [source,filters,sink].flatten.each{|proc|proc.logger = logger }
    end

    def init_loggers name, options
      # log for success:
      @log_file = options.delete :log_file
      @log = Log.new @log_file if @log_file
      # logger for debug etc.
      @logger = options.delete(:logger){self.class.logger}
      @logger.progname = name if @logger.respond_to?(:progname=) && !@logger.progname
    end

    def process *pathes
      pathes = pathes.flatten
      return if pathes.empty?

      notify BeforeEvent.new(self, pathes)
      
      with_retry(pathes) do
        if auto
          process_auto pathes
        else
          process_chain pathes
        end
      end
      
    end

    def process_chain local_pathes
      Dir.mktmpdir do |tmp_dir|
        pathes = []
        sink_pathes = []
        with_timeout("processing chain for #{Utils.basenames(local_pathes).inspect}") do
          pathes = Utils.copy_files local_pathes, tmp_dir
          filters.each do |filter|
            pathes = filter.filter_files pathes
          end
          notify AfterFiltersEvent.new(self, pathes)
          sink_pathes = sink.put_files pathes
        end
        # success! is not included in the timeout
        success! local_pathes, pathes, sink_pathes
      end
    end

    def process_auto local_pathes
      Dir.mktmpdir do |tmp_dir|
        target_pathes = []
        sink_pathes = []

        with_timeout("processing auto for #{Utils.basenames(local_pathes).inspect}") do
          Utils.copy_files local_pathes, tmp_dir
          loop do
            done_pathes = []
            filters.each do |filter|
              source_pathes = filter.available_files tmp_dir
              logger.debug{"auto process: #{filter}. files: #{Utils.basenames(source_pathes).inspect}"} unless source_pathes.empty?
              filter.filter_files source_pathes
              Utils.delete_files! source_pathes
              done_pathes << source_pathes
            end
            break if done_pathes.flatten.empty?
          end
          # put remaining files to sink
          target_pathes = Utils.dir_files tmp_dir
          raise InterfaceError, "process_auto: no files remaining" if target_pathes.empty?

          notify AfterFiltersEvent.new( self, target_pathes )

          logger.debug{"auto process: putting #{target_pathes.inspect} to #{sink}"}
          sink_pathes = sink.put_files target_pathes
        end
                
        success! local_pathes, target_pathes, sink_pathes
      end
    end

    def success! source_pathes, target_pathes, sink_pathes
      return if source_pathes.empty?
      log.log(name, source_pathes, target_pathes) if log
      mark_done! source_pathes if mark_done
      notify SuccessEvent.new(self, source_pathes, target_pathes, sink_pathes)
    end

    def error! exception, source_pathes = nil
      msg = Utils.exception_to_s exception
      if source_pathes && !source_pathes.empty?
        logger.error{"#{Utils.basenames(source_pathes).inspect} failed. moving files to err. #{msg}"}
        Utils.append_suffix '.err', source_pathes
      else
        logger.error{"failed: #{msg}"}
      end
      notify ErrorEvent.new(self, source_pathes, msg)
    end

    def mark_done! source_pathes
      unless sink.is_a?(DirSink) && sink.dir == source.dir
        case mark_done
        when String 
          Utils.append_suffix(mark_done, source_pathes) 
        when :delete
          Utils.delete_files!(source_pathes)
        end
      end
    end

    def notify event
      changed
      notify_observers event
    rescue Exception => e
      msg = "#{e.message} (#{e.class})\n" << (e.backtrace || []).join("\n")
      logger.error{"notifying observers failed. #{event.inspect}. #{msg}"}
    end
  end
end
