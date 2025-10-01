module Interfaces
  class PasswordHider
    
    def initialize marker = 'PPASSSSWWOORRDD', hidden = 'HIDDEN'
      @marker, @hidden = marker, hidden
    end

    def hide s, hidden=nil
      replace s, hidden||@hidden
    end

    def unmask s
      replace s
    end

    def mask s
      "<#{@marker}>#{s}</#{@marker}>"
    end

    private 
    def replace s, with = '\1'
      # ? ungreedys the *. see http://www.regular-expressions.info/repeat.html
      s.gsub %r(<#{@marker}>(.*?)</#{@marker}>), with 
    end
  end
end
