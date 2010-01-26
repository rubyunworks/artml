# table.rb

module ARTML

  class Table < Structure
   
    attr_reader :lines, :scale, :remarks, :sections
    attr_accessor :form
  
    def initialize( parent, lines, name='', tags=[], scale='', remarks=[] )
      @lines = lines
      @scale = scale.strip.split('!').collect {|s| s.strip.empty? ? 'auto' : s.strip.downcase }[1..-1]
      @scale = [] if not @scale
      @form = tags.include?('form')
      @sections = []
      super( parent, name, tags )
      parse(lines)
    end
    
    # set yaml
    def to_yaml_properties
      super + [ '@scale', '@form', '@sections' ]
    end
    def to_yaml_type
      '!!table'
    end
    
    def children; @sections; end
    
    def parse(lines)
      section_lines = []
      lines.each do |line|
        if not section_lines.empty? and line[0..1] == '+='
          section_lines << line
          @sections << Section.new(self, section_lines, @scale)
          section_lines = [line]
        else
          section_lines << line
        end
      end
      # finish off last section
      if not section_lines.empty? 
        @sections << Section.new(self, section_lines, @scale)
      end
    end
        
  end  # Table

end  # ARTML
