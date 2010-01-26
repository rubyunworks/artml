
class ::ARTML::Adapters::XHTML
  class Cell < Component
    def write(i=nil)
      q = ''
      q << %Q{ <td}
      q << %Q{ id="#{self.name}"} if self.name
      q << %Q{ class="#{self.tag}"} if self.tag
      q << %Q{ width="#{self.width}"} if self.width
      q << %Q{ colspan="#{self.colspan}"} if self.colspan > 1
      q << %Q{ rowspan="#{self.rowspan}"} if self.rowspan > 1
      q << %Q{ align="#{self.alignment}"} #if self.alignment != 'left'
      q << self.apply_attributes
      q << %Q{>}
      @elements.each do |e|
        q << e.write(i)
      end
      q << %Q{</td>\n}
      return q
    end
  end
end
