
require 'succ/object'

module ARTML

  ### ##  #####  ####   ##  #  ##    #####
  ## # #  ##  #  ##  #  ##  #  ##    ##
  ##   #  ##  #  ##  #  ##  #  ##    ###
  ##   #  #####  ####   #####  ##### #####
  ########################################
  # namespace for adapters
  ########################################
  module Adapters
    class << self
      @@adapters = {}  # store adapters here
      # register adapter
      def register_adapter( a )
        aname = a.name.split('::').last.downcase
        @@adapters[aname] = a
      end
      def [](name); @@adapters[name.to_s.downcase]; end
      def adapters; @@adapters.dup; end
    end
  end
  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #########################################
  # base class for all adapters
  #########################################
  class Adapter 
    class << self
      # register adapter
      def inherited( a ); Adapters.register_adapter( a ); end
      # store components
      def register_component(component); (@components ||= []) << component; end
      def components; @components; end
      # acts as factory
      alias new2 new
      def new( adapter_name )
        a = Adapters[adapter_name].new2
      end
    end
    
    attr_reader :template, :form
    
    ### production process
    
    def <<( blueprint )
      setup( blueprint )
      start
    end
    
    # 
    def setup( template )
      @template = template
      # register all the yaml types for the adapters components
      self.class.components.each do |c|
        puts "Registering: #{c} as !!#{c.name.split('::').last.downcase}" if $DEBUG
        if c.respond_to?(:register_yaml_type)
          c.register_yaml_type( self ) 
        else
          YAML.add_private_type( c.name.split('::').last.downcase ) { |type, val| c.new( val, self ) }
        end
      end
      # reload the model
      @form = YAML.load( @template )
    end
    
    # 
    def start
      @form.write
    end
  
  end
  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #########################################
  # base class for all plugable components
  #########################################
  class Adapter::Component
    
    def self.inherited( c )
      puts "Registering #{c.name}" if $DEBUG
      adapter_class = instance_eval( '::'<<c.name.split('::')[0..-2].join('::') )
      adapter_class.register_component( c )
    end
    
    def initialize( component_val, adapter )
      if component_val.kind_of?(Hash)
        with_readers( component_val )
      else
        self.replace( component_val )
      end
      @adapter = adapter
    end
    
    def form; @adapter.form; end
    def meta; metadata; end
    
  end
  
end
