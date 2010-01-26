# form.rb

require 'cgi'  # for pretty printing

class ::ARTML::Adapters::XHTML
  class Form < Component
    
    #def self.register_yaml_type( parent )
    #  YAML.add_private_type( "model" ) { |type, val| ::ARTML::Adapters::XHTML::Form.new( val, parent ) }
    #end
    
    # creates entire xhtml page with stylesheet and table
    def write
      xhtml = ''
      xhtml << %Q{ 
        <html>
        <head>
        <title>#{self.metadata['title']}</title>
      }
      if self.meta['links']
        self.meta['links'].each { |link|
          xhtml << %Q{ <link }
          link.each_pair{|k,v| xhtml << %Q{ #{k}="#{v}" } }
          xhtml << %Q{ /> \n }
        }
      end
      if self.meta['stylesheets']
        self.meta['stylesheets'].each { |css|
          xhtml << %Q{ <link type="text/css" src="#{css}" /> \n }
        }
      end
      if self.meta['javascripts']
        self.meta['javascripts'].each { |js|
          xhtml << %Q{ <script langauge="javascript" src="#{js}"></script> \n }
        }
      end
      xhtml << %Q{
        <style type="text/css">
           body { margin: 0px; padding 0px; border: none; }
          table { margin: 0px auto 0px auto; padding 0px; }
          #{build_css(self.style)}
        </style>
      }
      xhtml << %Q{ </head> }
      xhtml << %Q{ <body onload="javascript: loadScript();" }
      if self.style.has_key?('body')
        xhtml << %Q{style="}
        self.style['body'].each {|a,v| xhtml << " #{a}: #{v};" }
        xhtml << %Q{"}
      end
      xhtml << %Q{>}
      xhtml << %Q{
          #{self.metadata['prepend']}
          #{@main.write}
          #{self.metadata['append']}
        </body>
        </html>
      }
      return CGI::pretty(xhtml)
      #return PrettyXML.pretty(html, 2)
    end
    
    # creates the html stylesheet from style_hash
    def build_css(style_hash)
      q = ''
      q << style_hash.collect { |k, v|
        if not v.empty?
          q2 = ( k =~ /\./ ? ( k[-1..-1] == '.' ? "#{k[0..-2]}" : "#{k}" ) : "##{k}" )
          q2 << ' {' << v.collect{| k2, v2 | " #{k2}: #{v2}" }.join( ';' ) << ' }'
          q2
        end
      }.join("\n")
      return q
    end
  
  end
end
