
class ::ARTML::Adapters::XHTML
  class Counter < Component
    def write(i=nil)
      if @name == 'index'
        q = "#{i}"
      else
        q = "#{i+1}"
      end
      return q
    end
  end
end

