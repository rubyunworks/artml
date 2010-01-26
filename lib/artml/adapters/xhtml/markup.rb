require 'redcloth'

class ::ARTML::Adapters::XHTML
  class Markup < Component
    def write(i=nil)
      v = self.value
      v = v[i] if i
      q = ''
      #apply_format(@name.gsub(/\s/, '&nbsp;'), nil, cell.class)
      q << ::RedCloth.new("#{v}").to_html
      #q << CGI.escapeHTML(v) if v #.gsub(/\s/, '&nbsp;').gsub(/["]/, '')
      #q << "\n"
      return q
    end
  end
end
