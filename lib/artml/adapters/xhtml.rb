# ArtML - XHTML Adapter for ArtML, a Graphical Ascii Art Form and Table Template Tool
# Copyright (c) 2004 Thomas Sawyer, License

module ARTML::Adapters

  # static xhtml adapter
  class XHTML < ::ARTML::Adapter
    
    # base class for XHTML components
    class Component < ::ARTML::Adapter::Component
      def apply_attributes
        attrib = ''
        attrib << ' style="' + self.tag_style.collect { |k,v| %Q{#{k}: #{v};} }.join(' ') + '"'
        attrib
      end
    end
  
    # load external component classes
    pindir = File.join(File.dirname(File.expand_path(__FILE__)), "xhtml")
    pins = Dir["#{pindir}/*"]  # or **/* ?
    pins.each { |pin| require pin }
    
  end

end
