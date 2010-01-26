# ArtML - XHTML Adapter for ArtML, a Graphical Ascii Art Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License

require 'cgi'  # this is required for pretty output

module ARTML
  
  module Adapters

    module XHTML
      
      def XHTML.plugin
        
        ARTML::Structure.class_eval { include Adapters::XHTML::Structure }
        ARTML::Model.class_eval { include Adapters::XHTML::Model }
        ARTML::Table.class_eval { include Adapters::XHTML::Table }
        ARTML::Section.class_eval { include Adapters::XHTML::Section }
        ARTML::Cell.class_eval { include Adapters::XHTML::Cell }
        
        ARTML::Elements::Element.class_eval { include Adapters::XHTML::Elements::Element }
        ARTML::Elements::Label.class_eval { include Adapters::XHTML::Elements::Label }
        ARTML::Elements::Hidden.class_eval { include Adapters::XHTML::Elements::Hidden }
        ARTML::Elements::TextInput.class_eval { include Adapters::XHTML::Elements::TextInput }
        ARTML::Elements::Button.class_eval { include Adapters::XHTML::Elements::Button }
        ARTML::Elements::Selector.class_eval { include Adapters::XHTML::Elements::Selector }
        ARTML::Elements::Radio.class_eval { include Adapters::XHTML::Elements::Radio }
        ARTML::Elements::Counter.class_eval { include Adapters::XHTML::Elements::Counter }
        ARTML::Elements::General.class_eval { include Adapters::XHTML::Elements::General }
      
      end
    
      
      # Modify Structures
    
      module Structure
      
        def apply_attributes
          _attrib = ''
          _attrib << self.data.collect { |_k, _v| %Q{#{_k}="#{_v}"} }.join(' ')
          _attrib << ' style="' + self.style.collect { |_k, _v| %Q{#{_k}: #{_v};} }.join(' ') + '"'
          return _attrib
        end
        
        #def get_attributes  #(_name, _classes)
        #  _a = {}
        #  if parent(Model).style.has_key?("#{aclass}")
        #    _a.update(self.classes["#{aclass}"])
        #  end
        #  if self.names.has_key?(aname)
        #    a.update(@model.names[aname])
        #  end
        #  if self.elements.has_key?("#{aname}.#{aclass}")
        #    a.update(@attributes["#{aname}.#{aclass}"])
        #  end
        #  return a
        #end
      
      end
      
      module Model
        
        def show
          puts build
        end
  
        # creates entire xhtml page with stylesheet and table
        def build  #title, form_name, form_action, script='', append_body='')
        
          @disable = []
          
          xhtml = %Q{ 
            <html> 
            <head>
            <title>#{self.meta['title']}</title>
          }
          if self.meta['stylesheets']
            self.meta['stylesheets'].each { |css|
              xhtml += %Q{ <link type="text/css" src="#{css}" /> \n }
            }
          end
          if self.meta['javascripts']
            self.meta['javascripts'].each { |js|
              xhtml += %Q{ <script langauge="javascript" src="#{jc}" /> \n }
            }
          end
          #xhtml += %Q{
          #  <style type="text/css">
          #    #{build_css(self.style)}
          #  </style>
          #}
          xhtml += %Q{ </head> }
          xhtml += %Q{
            <body onload="javascript: loadScript();">
              #{self.meta['prepend']}
              #{self.main.build}
              #{self.meta['append']}
            </body>
            </html>
          }
          return CGI::pretty(xhtml)
          #return PrettyXML.pretty(html, 2)
        end
      
        # creates the html stylesheet from @style hash
        def build_css(style_hash)
          style_hash.collect { |k, v|
            %Q{#{k} {#{v.collect { |k2, v2| "#{k2}: #{v2}" }.join(';')}}} if not v.empty? 
          }.join("\n")
        end
      end  # Model
      
      module Table
        def build(i=nil)
          hs = ''
          self.sections.each do |section|
            if section.repeat
              repeat_length(section).times do |j|
                hs << section.build(j)
              end
            else
              hs << section.build(i)
            end
          end
          return %Q{
            <form name="#{self.name}" action="#{self.data['action']}" method="post">
            <table id="#{self.__id__}" name="#{self.name}" class="#{self.class}" #{apply_attributes}>
            #{hs}
            </table>
            </form>
          }
        end
      end
      
      module Section
        def build(i=nil)
          rows = []
          rowy = nil
          hr = ''
          self.cells.each do |cell|
            hc = ''
            content = cell.build(i)
            if content
              hc << %Q{ <td}
              hc << %Q{ class="#{cell.class}"} if cell.class
              hc << %Q{ width="#{cell.width}"} if cell.width
              hc << %Q{ colspan="#{cell.colspan}"} if cell.colspan > 1
              hc << %Q{ rowspan="#{cell.rowspan}"} if cell.rowspan > 1
              hc << %Q{ align="#{cell.alignment}"} #if cell.alignment != 'left'
              hc << %Q{>#{content}</td>\n}
            end
            if rowy == cell.y
              hr << hc
            else
              rows << "<tr>#{hr}</tr>" if not hr.empty?
              rowy = cell.y
              hr = hc
            end
          end
          rows << "<tr>#{hr}</tr>" #if not hr.empty?
          return rows.join("\n") << "\n" # add the section rows
        end
      end
     
      module Cell
        def build(i=nil)
          q = ''
          self.elements.each do |element|
            #if not @disable.include?(element.name)
#p element.name, element.class
              q << element.write
            #end
          end
          return q
        end
      end
      
      
      # Modify Elements
      
      module Elements
        
        module Element
        end
        
        module Label
          def write
            q = @name.gsub(/\s/, '&nbsp;') #apply_format(self.name.gsub(/\s/, '&nbsp;'), nil, cell.class)
            q << "\n"
            return q
          end
        end
        
        module Hidden
          def write
            v = @cells[self.name]
            #v = v[i.to_i] if i
            #v = apply_format(v, self.name, self.class)
            q = %Q{ <input type="hidden"}
            q << %Q{ class="#{self.class}"} if self.class
            q << %Q{ name="#{self.name}" value="#{v}" #{apply_attributes}/>}
            q << "\n"
            return q
          end
        end
        
        module TextInput
          def write
            q = ''
            if self.size == 1
              v = self.data['value']
              #v = v[i.to_i] if i
              #v = apply_format(v, self.name, self.class)
              q << %Q{ <input type="text"}
              q << %Q{ class="#{self.class}"} if self.class
              q << %Q{ name="#{self.name}" value="#{v}" #{apply_attributes} />}
            else              
              v = self.data['value']
              #v = v[i.to_i] if i
              #v = apply_format(v, self.name, self.class)
              q << %Q{ <textarea}
              q << %Q{ class="#{self.class}"} if self.class
              q << %Q{ name="#{self.name}" #{apply_attributes}>#{v}</textarea>}
            end
            q << "\n"
            return q
          end
        end
        
        module Button
          def write
            q = ''
            v = self.data['value']
            #v = v[i.to_i] if i
            v = self.name if not v  # for a submit button the value will be same as the name if not given
            #v = apply_format(v, self.name, self.class)
            button_type = 'submit'
            #button_type = 'button' if html_button_onscript?(self.name, self.class)
            q << %Q{ <button type="#{button_type}"}
            q << %Q{ class="#{self.class}"} if self.class
            q << %Q{ name="#{self.class}"} if self.class
            q << %Q{ value="#{v}" #{apply_attributes}>#{self.name}</button>}
            q << "\n"
            return q
          end
        end

        module Selector
          def write
            q = ''
            v = "" #@cells[self.name]
            #v = v[i.to_i] if i
            #v = apply_format(v, self.name, self.class)
            q << %Q{ <select }
            q << %Q{ class="#{self.class}"} if self.class
            q << %Q{ size="#{self.size}"} if self.size > 1
            q << %Q{ name="#{self.name}" #{apply_attributes}>}
#p self.name
#p self.data
            raise "Selector option list missing for #{self.name}" if not self.data['options']
            self.data['options'].each do |option|
              if option.is_a?(Array)
                option_value = option[0]
                option_visible = apply_format(option[1], self.name, self.class)
                q << %Q{ <option value="#{option_value}"}
                q << %Q{ selected="true"} if option_value == "#{v}"
                q << %Q{>#{option_visible}</option> }
              else
                option_value = option #apply_format(option, self.name, self.class)
                q << %Q{ <option value="#{option_value}"}
                q << %Q{ selected="true"} if option_value == "#{v}"
                q << %Q{>#{option_value}</option>}
              end
            end
            q << %Q{ </select>}
            q << "\n"
            return q
          end
        end
        
        module Radio
          def write
            q = ''
            if self.size == 1  # check box
              v = self.data['value']
              #v = v[i.to_i] if i
              #v = apply_format(v, self.class)
              q << %Q{ <input type="checkbox"}
              q << %Q{ class="#{self.class}"} if self.class
              q << %Q{ name="#{self.name}" value="#{v}" }
              q << %Q{ checked="true"} if self.data['checked']
              q << %Q{ #{apply_attributes} />}
            else
              v = self.data['value']
              #v = v[i.to_i] if i
              v = self.name if not v  # for a radio button the value will be same as the name if not given
              #v = apply_format(v, self.name, self.class)
              q << %Q{ <input type="radio"}
              q << %Q{ class="#{self.class}"} if self.class
              q << %Q{ name="#{self.name}"} if self.name
              q << %Q{ value="#{self.name}"}
              q << %Q{ checked="true"} if v and self.name == v.to_s
              q << apply_attributes
              q << %Q{>#{v}</input>}
            end
            q << "\n"
            return q
          end
        end
        
        module Counter
          def write
            if self.name == 'index'
              q = "#{i}"
            else
              q = "#{i+1}"
            end
            return q
          end
        end          
        
        module General
          def write(i=nil)
            # general element may be another table
            tbl = @model.table?(self.name)
            if tbl
              q = tbl.build(i)
            else
              v = self.data['value']
              #v = v[i.to_i] if i
              #v = apply_format(v, nil, cell.class)
              q = v.to_s
            end
            return q
          end
        end

      end  # Elements
       
    end  # XHTML

  end  # Adapters
  
end  # ARTML
