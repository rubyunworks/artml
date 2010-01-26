
class ::ARTML::Adapters::XHTML
  class Hidden < Component
    def write(i=nil)
      v = self.value
      v = v[i] if i
      #v = apply_format(v, @element.name, @element.class)
      q = %Q{ <input type="hidden"}
      q << %Q{ class="#{@tag}"} if @tag
      q << %Q{ name="#{@name}" value="#{v}" #{apply_attributes}/>}
      q << "\n"
      return q
    end
  end
end


