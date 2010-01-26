
class ::ARTML::Adapters::XHTML
  
  class Button < Component
    def write(i=nil)
      q = ''
      v = self.value
      v = v[i] if i
      v = @name if not v  # for a submit button the value will be same as the name if not given
      #v = apply_format(v, @element.name, @element.class)
      button_type = 'submit'
      #button_type = 'button' if html_button_onscript?(self.name, self.class)
      q << %Q{ <button type="#{button_type}"}
      q << %Q{ class="#{@tag}"} if self.tag
      q << %Q{ name="#{@class}"} if self.class
      q << %Q{ value="#{v}" #{apply_attributes}>#{@name}</button>}
      q << "\n"
      return q
    end
  
  end
  
end
