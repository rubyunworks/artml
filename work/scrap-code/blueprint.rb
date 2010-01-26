# template.rb

require 'yaml'
require 'succ/hash'

module ARTML

  ### these are the various parts of a composition

  # layout
  YAML.add_domain_type( "artml.rubyforge.org,2004", "layout" ) { |type, val| 
    def val.tag; '!!layout'; end; val 
  }
  YAML.add_private_type( "layout" ) { |type, val| val }
  
  # components
  YAML.add_domain_type( "artml.rubyforge.org,2004", "components" ) { |type, val| 
    def val.tag; '!!components'; end; val 
  }
  YAML.add_private_type( "components" ) { |type, val| val }  
  
  # style
  YAML.add_domain_type( "artml.rubyforge.org,2004", "stylesheet" ) { |type, val|
    def val.tag; '!!stylesheet'; end; val 
  }
  YAML.add_private_type( "stylesheet" ) { |type, val| val }
  
  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #########################################
  # blueprint - unified composition object
  #########################################
  class Blueprint

    attr_accessor :layout, :style, :components
  
    def initialize(*yio)
      @layout = ''
      @style = {}
      @components = {}
      add(*yio)
      raise "no layout" if @layout.empty? # =~ /\A\s*\Z/
    end
    
    def add( *yio )
      yio.each do | y |
        YAML::load_documents( y ) do |doc|
          add_copy( doc )
        end
      end
    end
    
    def add_copy( c )
      case c.tag
        when '!!layout'; @layout += "\n#{c}"
        when '!!stylesheet'; @style += c
        when '!!components'; @components += c
        else; raise("undefined part: \n #{c}")
      end
    end
    
    def construct
      self.to_yaml
    end
        
  end  # Blueprint
  
end


# some test code

#class YAML::Syck::PrivateType
#  def to_yaml_type
#    "!!#{@type_id}"
#  end
#end

#class YAML::Syck::DomainType
#  def to_yaml_type
#    "!#{@domain}/#{@type_id}"
#  end
#end
