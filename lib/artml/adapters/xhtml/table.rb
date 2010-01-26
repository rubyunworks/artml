
class ::ARTML::Adapters::XHTML
  class Table < Component
    def write(i=nil)
      hs = ''
      @sections.each do |s|
        if s.repeat
          s.repeat_length.times do |j|
            hs << s.write(j)
          end
        else
          hs << s.write(i)
        end
      end
      q = ''
      q << %Q{<form name="#{@name}" action="#{self.data['action']}" method="post">} if @form
      q << %Q{<table id="#{@name}" class="#{@tag}" cellpadding="0px" cellspacing="0px" #{apply_attributes}>}
      q << hs
      q << %Q{</table>}
      q << %Q{</form>} if @form
      q
    end 
  end
end

