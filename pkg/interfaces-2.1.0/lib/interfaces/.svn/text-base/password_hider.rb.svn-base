require 'rexml/document'
require 'rexml/text'

module Interfaces
  class PasswordHider
    
    def initialize( marker = 'PPASSSSWWOORRDD', hidden = 'HIDDEN')
      @marker, @hidden = marker, hidden
    end

    def hide(s,hidden=nil)
      replace(s){hidden||@hidden}
    end

    def unmask(s)
      replace(s){|el|el.text}
    end

    def mask(s)
      doc = REXML::Document.new
      el = REXML::Element.new @marker
      el.text = s
      doc.add_element el
      doc.to_s
    end

    private
    def replace(s)
      doc = REXML::Document.new("<ROOT>#{s}</ROOT>")
      doc.elements["/ROOT"].each_element(@marker) do |el|
        el.parent.replace_child(el, REXML::Text.new(yield el))
      end
      doc.elements["/ROOT"].children.join ""
    end

  end
end
