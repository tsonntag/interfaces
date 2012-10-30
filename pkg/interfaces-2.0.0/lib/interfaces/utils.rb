require 'fileutils'

module Interfaces
  module Utils
    class << self
      def delete_files!(pathes)
        [pathes].flatten.each{|p|FileUtils.rm(p)}
      end

      def move_to_old(pathes)
        [pathes].flatten.each{|p|FileUtils.mv(p,"#{p}.old")}
      end

      def move_to_err(pathes)
        [pathes].flatten.each{|p|FileUtils.mv(p,"#{p}.err")}
      end

      def basenames(pathes)
        pathes && pathes.map{|p|File.basename(p)}
      end

      def copy_files(pathes,dir)
        pathes.map do |p|
          FileUtils.cp p,dir
          File.join dir, File.basename(p)
        end
      end

      def untmp_pathes(pathes)
        [pathes].flatten.map do |p|
          untmp = p.gsub(/\.tmp\Z/,'')
          tmp = untmp + '.tmp'
          FileUtils.mv tmp, untmp
          untmp
        end
      end

      # returns target_pathes
      def tmped_copy(pathes,dir)
        tmps = [pathes].flatten.map do |path|
          file = File.basename(path)
          tmp = File.join(dir,file + '.tmp')
          FileUtils.cp path, tmp
          tmp
        end
        untmp_pathes tmps
      end

      def dir_files(dir)
        Dir[File.join(dir, '*')].select do |path|
          name = File.basename path
          name !~ /\A.*\.(tmp|TMP|temp|old|err|\$00)\Z/ and File.file?(path)
        end
      end

      def exception_to_s(e)
        "#{e.message} (#{e.class})\n" << (e.backtrace || []).join("\n")
      end
    end
  end
end