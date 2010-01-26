# artml.rb

require 'yaml'

# blueprint
require 'artml/blueprint'

# adapters
require 'artml/adapters'
require 'artml/adapters/xhtml'


module ARTML
  # main method
  def self.load( adapter_name, *y )
    case adapter_name.to_s.downcase
    when 'blueprint'
      ARTML::Blueprint.new( *y ).construct
    when 'preprint'
      ARTML::Blueprint.new( *y ).preprint
    else
      b = ARTML::Blueprint.new( *y ).construct
      a = ARTML::Adapter.new( adapter_name )
      a << b
    end
  end
end
