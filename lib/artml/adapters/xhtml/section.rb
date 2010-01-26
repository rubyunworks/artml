
class ::ARTML::Adapters::XHTML
  class Section < Component
    def write(i=nil)
      rows = []
      rowy = nil
      hr = ''
      @cells.each do |c|
        hc = ''
        if ! c.elements.empty?
          hc << c.write(i)
        #content = c.write(i)
        #if content
          #hc << %Q{ <td}
          #hc << %Q{ class="#{c.tag}"} if c.tag
          #hc << %Q{ width="#{c.width}"} if c.width
          #hc << %Q{ colspan="#{c.colspan}"} if c.colspan > 1
          #hc << %Q{ rowspan="#{c.rowspan}"} if c.rowspan > 1
          #hc << %Q{ align="#{c.alignment}"} #if c.alignment != 'left'
          #hc << c.apply_attributes
          #hc << %Q{>#{content}</td>\n}
        end
        if rowy == c.y
          hr << hc
        else
          rows << "<tr>#{hr}</tr>" if not hr.empty?
          rowy = c.y
          hr = hc
        end
      end
      rows << "<tr>#{hr}</tr>" #if not hr.empty?
      return rows.join("\n") << "\n" # add the section rows
    end
  end
end
