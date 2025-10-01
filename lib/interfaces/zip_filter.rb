require 'zip'

module Interfaces
  class ZipFilter < Filter
    attribute :zip_filename
    validates_presence_of :zip_filename

    def do_filter_files pathes
      dir = File.dirname pathes.first
      target_path = File.join dir, zip_filename
      Zip::ZipOutputStream.open(target_path) do |zos|
        pathes.each do |path|
          zos.put_next_entry File.basename(path)
          zos.write IO.read(path)
        end
      end
      logger.info{"#{self}: zipped #{Utils.basenames(pathes).join(',')} => #{zip_filename}"}
      [target_path]
    end
  end
end
