
class ::ARTML::Adapters::XHTML
  class Field < Component
    def write(i=nil)
      v = self.value
      v = v[i] if i
      #v = apply_format(v, @name, self.class)
      q = ''
      if @size == 1
        q << %Q{ <input type="text"}
        q << %Q{ class="#{@tag}"} if @tag
        q << %Q{ name="#{@name}" value="#{v}" #{apply_attributes} />}
      else              
        q << %Q{ <textarea}
        q << %Q{ class="#{@tag}"} if @tag
        q << %Q{ name="#{@name}" size="#{@size}" #{apply_attributes}>#{v}</textarea>}
      end
      q << "\n"
      return q
    end
  end
end
