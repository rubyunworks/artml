# element.rb

module ARTML
  
   STD_ELEMENTS = { 
      nil => :General,
      "'" => :Text,
      '"' => :Markup,
      '*' => :Hidden,
      '[' => :Field,
      '<' => :Button,
      '{' => :Selector,
      '(' => :Radio,
      '#' => :Counter
    }

  # element factory
  module ElementFactory
    def self.new( parent, literal )
      e = STD_ELEMENTS[literal[0..0]] || STD_ELEMENTS[nil]
      c = instance_eval "Elements::#{e}"
      c.new( parent, literal )
    end
  end

  # base class for all elements  
  class Element < ::ARTML::Structure
    attr_reader :literal, :size
    def initialize( parent, literal )
      raise "empty literal" if literal.empty?
      @literal = literal.strip
      @size = 0
      if literal[0..0] !~ /\w/
        if literal[0..0] =~ /[\[{(<]/
          @size = literal.count(literal[0..0])
        else
          @size = literal.count(literal[0..0]) / 2
        end
      end
      name = split_name(literal[@size..-(@size+1)])
      tags = split_tags(literal[@size..-(@size+1)])
      super( parent, name, tags )
    end
    # set yaml
    def to_yaml_properties
      super + [ '@literal', '@size' ]
    end
    def to_yaml_type
      '!!element'
    end
  end
  
  # standard elements  
  module Elements
    
    STD_ELEMENTS.values.each { |e|
      class_eval <<-EOS
        class #{e} <  Element
          def initialize( parent, literal ); super; end
          def to_yaml_type; '!!#{e.to_s.downcase}'; end
        end
      EOS
    }
        
  end  # Elements

end
