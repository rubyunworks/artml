require 'redcloth'
 
class ::ARTML::Adapters::XHTML
  class General < Component
    def write(i=nil)
      # general element may be another table
      tbl = self.form.tables.detect { |t| t.name == @name }
      if tbl
        q = tbl.write(tbl)
      else
        v = self.value
        v = v[i] if i
        q = ::RedCloth.new("#{v}").to_html
      end
      return q
    end
  end
end
