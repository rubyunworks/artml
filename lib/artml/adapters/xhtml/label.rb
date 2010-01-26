require 'cgi'

class ::ARTML::Adapters::XHTML
  class Label < Component
    def write(i=nil)
      q = CGI.escapeHTML(self.literal[1..-2])
      q
    end
  end
end
