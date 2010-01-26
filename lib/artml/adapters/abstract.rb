# ArtML(tm) - Abstract Adapter for ArtML, a Graphical Ascii Art Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License
# ArtML is a tradmark of Thomas Sawyer, 2004

require 'cgi'  # this is required for pretty output

module ARTML::Adapters

  # abstract adapter
  class Abstract

    ::ARTML::Adapters.register(:abstract, self)
    
    def initialize( blueprint )
      @blueprint = blueprint
    end
    
    def set
      register_yaml_types
      @production = YAML::load(blueprint)
    end
    
    def register_yaml_types
      
      YAML.add_private_type( "table" ) { |type, val| Table.new(val) }
      YAML.add_private_type( "section" ) { |type, val| Section.new(val) }
      
      
    end
    
    def start
      a.write_model( @production.model )
    end
    
    # creates entire xhtml page with stylesheet and table
    def write_model(m)
      q = ''
      q << m.meta.inspect
      q << m.style.inspect
      q << m.data.inspect
      q << write_table(m.main)
      q
    end

    def write_table(t, i=nil)
      q = ''
      q << t.meta.inspect
      q << t.style.inspect
      q << t.data.inspect
      t.sections.each do |s|
        if s.repeat
          s.repeat_length.times do |j|
            q << write_section(s, j)
          end
        else
          q << write_section(s, i)
        end
      end
      q
    end
     
    def write_section(s, i=nil)
      q = ''
      q << s.meta.inspect
      q << s.style.inspect
      q << s.data.inspect
      s.cells.each do |c|
        q << write_cell(c, i)
      end
      q
    end
    
    def write_cell(c, i=nil)
      q = ''
      q << c.meta.inspect
      q << c.style.inspect
      q << c.data.inspect
      c.elements.each do |e|
        q << write_element(e, i)
      end
      q
    end
    
    def write_element(e, i)
      q << e.meta.inspect
      q << e.style.inspect
      q << e.data.inspect
      el = element_factory( e )
      q << el.write
      q
    end

    # maps the built-in literals to XHTML elements
    def element_factory( e )
      case e.literal[0..0]
        when '"'
          c = Elements::Label
        when '*'
          c = Elements::Hidden
        when '['
          c = Elements::Field
        when '<'
          c = Elements::Button
        when '{'
          c = Elements::Selector
        when '('
          c = Elements::Radio
        when '#'
          c = Elements::Counter
        else
          c = Elements::General
      end
      return c.new( e )
    end
     
    # namespace for elements
    module Elements
          
      class Structure
        def initialize( element )
           @element = element
        end
      end

      class General < Structure
        def write(i=nil)
          self.inspect
          # general element may be another table
          tbl = @element.model.table?(@element.name)
          if tbl
            q = write_table(tbl, i)
          else
            v = @element.data['value']
            v = v[i] if i
            #v = apply_format(v, nil, cell.class)
            q = v.to_s
          end
          q
        end
      end

      class Label < Structure
        def write(i=nil)
          self.inspect
        end
      end
      
      class Hidden < Structure
        def write(i=nil)
          self.inspect
        end
      end
      
      class Field < Structure
        def write(i=nil)
          self.inspect
        end
      end
      
      
      
    end  # Elements
    
  end  # XHTML

end  # ARTML::Adapters
