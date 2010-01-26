#require 'redcloth'

#YAML.add_private_type( 'redcloth' ) { |type, val| ::RedCloth.new( val ).to_html }

#class ::ARTML::Adapters::XHTML
#  class RedCloth < Component
#     def self.register_yaml_type( parent )
#       
#       YAML.add_domain_type( 'hobix.com,2004', 'redcloth' ) { |type, val| ::RedCloth.new( val ).to_html }
#     end
#  end
#end
