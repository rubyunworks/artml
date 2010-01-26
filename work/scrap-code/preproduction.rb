# copy.rb

require 'yaml'

module ARTML 

  def self.load(*yarts)
    Copy.new(*yarts)
  end
  
  class CopyModel < String
    YAML.add_domain_type( "artml.rubyforge.org,2004", "model" ) { |type, val| CopyModel.new.replace(val) } 
    YAML.add_domain_type( "artml.rubyforge.org,2004", "art" ) { |type, val| CopyModel.new.replace(val) } 
    def yaml_type; '!!copy_model'; end
  end
  
  

  class Copy
    attr_accessor :models, :metas, :styles, :datas
  
    def initialize
      @models = []; @metas = []; @styles = []; @datas = []
      
    end
    

    def add_copy(*yarts)
      puts doc.class
          case doc
          when Model
            @models << doc
          when Meta
            @metas << doc
          when Style
            @styles << doc
          when Data
            @datas << doc
          else
            raise("undefined part: \n #{doc}")
          end
        end
      end
      raise "no model" if @models.empty?
    end  
    def printcopy; self.to_yaml; end
  end
  
end
