module Interfaces
  class CmdFilterError < StandardError; end

  # subclasses must implement #cmd(path)
  class CmdFilter < Filter

    validate do |filter|
      begin
        filter.cmd('test')
      rescue Exception => e
        filter.errors.add :base, "#{self}: invalid cmd. #{e}"
      end
    end

    def do_filter_file path
      command = cmd path
      logger.info{"#{self}: calling #{hide(command)}"}
      #unless system(command)
      #  raise CmdFilterError, "#{path} failed: #{$?}"
      #end
      require 'open3'
      Open3.popen3(unmask(command)) do |stdin,stdout,stderr|
        threads = []
        threads << Thread.new do
          while out=stdout.gets do debug_out(out,"stdout: ") end
        end
        threads << Thread.new do
          while err=stderr.gets do debug_out(err,"stderr: ") end
        end
        threads.each &:join
      end
    end

    private
    def debug_out(line,prefix)
      logger.debug{"#{self}: #{prefix} #{line}"} if line && !line.strip.empty?
    end
  end
end
