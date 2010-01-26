# structure.rb

module ARTML

  #@@prefix = ''

  def self.prefix
    @@prefix ||= ''
  end
    
  def self.prefix=(prefix)
    @@prefix = prefix
  end
  
  
  module Utils
  
    # returns the first word match
    def split_name(line)
      re = /^\s*(\w+)/
      md = re.match(line)
      return md ? md[1] : ''
    end
    
    # returns a list of all .word matches
    def split_tags(line)
      md = line.scan(/\.(\w+)\s*?/)
      md ? md.flatten : []
    end
  
    # add a prefix if name starts with ^
    # bug? b/c name is just word characters
    def fix_name(name)
      if name[0,1] == '^'
        return "#{ARTML.prefix}#{name[1..-1].strip}"
      else
        return name.strip
      end
    end
    
  end  # Utils
  
  
  # base class for all parts of the model
  class Structure
    
    include Utils
  
    attr_reader :parent, :model
    attr_accessor :name, :tags
    attr_reader :style, :data
    
    def initialize( parent, name=nil, tags=[] )
      # set parent and model
      @parent = parent
      @model = parent.model
      @name = name
      @tags = tags
      style_set
      data_set
    end
    
    # set yaml
    def to_yaml_properties
      @tag = tag()
      [ '@parent', '@name', '@tags', '@tag', '@data', '@style' ]
    end
    def to_yaml_type
      '!!structure'
    end
    
    def style_set
      @style = {}
      @tags.each { |t| @style.update(self.model.style[t]) if self.model.style.has_key?(t) } if @tags
      @style.update( self.model.style[@name] ) if self.model.style.has_key?( @name )
      @style
    end
    
    def data_set
      @data = {}
      @tags.each {|t| @data.update( self.model.data[t] ) if self.model.data.has_key?( t ) } if @tags
      if self.model.data.has_key?( @name )
        if self.model.data[@name].kind_of?(Hash)
          @data.update( self.model.data[@name] )
        else
          @data['value'] = self.model.data[@name]
        end
      end
      @data
    end
    
    def tag
      tags[0]
    end
    
    def tag=( x )
      tags.unshift( x )
    end
    
  end  # Structure
  
end  # ARTML

