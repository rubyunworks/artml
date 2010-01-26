
class ::ARTML::Adapters::XHTML
  class Selector < Component
    def write(i=nil)
      q = ''
      v = self.data['value']
      v = v[i] if i
      #v = apply_format(v, @element.name, @element.class)
      q << %Q{ <select }
      q << %Q{ class="#{@tag}"} if @tag
      q << %Q{ size="#{@size}"} if @size > 1
      q << %Q{ name="#{@name}" #{apply_attributes}>}
      raise "Selector option list missing for #{@name}" if not self.data['options']
      self.data['options'].each do |option|
        if option.is_a?(Array)
          option_value = option[0]
          option_visible = apply_format(option[1], @name, self.class)
          q << %Q{ <option value="#{option_value}"}
          q << %Q{ selected="true"} if option_value == "#{v}"
          q << %Q{>#{option_visible}</option> }
        else
          option_value = option #apply_format(option, @element.name, @element.class)
          q << %Q{ <option value="#{option_value}"}
          q << %Q{ selected="true"} if option_value == "#{v}"
          q << %Q{>#{option_value}</option>}
        end
      end
      q << %Q{ </select>}
      q << "\n"
      return q
    end
  end
end    
