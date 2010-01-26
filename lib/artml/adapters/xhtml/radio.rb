
class ::ARTML::Adapters::XHTML
  class Radio < Component
    def write(i=nil)
      v = self.value
      v = v[i] if i
      q = ''
      if @size == 1  # check box
        #v = apply_format(v, @element.class)
        q << %Q{ <input type="checkbox"}
        q << %Q{ class="#{@tag}"} if @tag
        q << %Q{ name="#{@name}" value="#{v}" }
        q << %Q{ checked="true"} if self.data['checked']
        q << %Q{ #{apply_attributes} />}
      else
        v = @element.name if not v  # for a radio button the value will be same as the name if not given
        #v = apply_format(v, @element.name, @element.class)
        q << %Q{ <input type="radio"}
        q << %Q{ class="#{@tag}"} if @tag
        q << %Q{ name="#{@name}"} if @name
        q << %Q{ value="#{@name}"}
        q << %Q{ checked="true"} if v and @name == v.to_s
        q << apply_attributes
        q << %Q{>#{v}</input>}
      end
      q << "\n"
      return q
    end
  end
end
