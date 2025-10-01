module Interfaces

  # Base class for remote sources.
  # 
  # Subclasses must implement #get_remote_files
  # which must copy remote files to _dir_
  class RemoteSource < Source

    attribute :remote_mark_done, default: '.old'

    validate do |source|
      begin
        Utils.validate_mark_done source.remote_mark_done
      rescue Exception => e
        source.errors.add :base, "invalid remote_mark_done #{source.remote_mark_done.inspect}"
      end
    end

    def do_get_files regexp
      get_remote_files regexp
      get_local_files regexp
    end

    def to_s
      super.to_s + "(#{dir})"
    end

  end
end
