module Interfaces

  # Base class for remote sources.
  # 
  # Subclasses must implement #get_remote_files
  # which must copy remote files to _dir_
  class RemoteSource < Source

    def do_get_files regexp
      get_remote_files regexp
      get_local_files regexp
    end

    def to_s
      super.to_s + "(#{dir})"
    end

  end
end
