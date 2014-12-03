module Interfaces
  class DirSource < Source

    def do_get_files regexp
      get_local_files regexp
    end

    def to_s
      super.to_s + "(#{dir})"
    end
  end

end
