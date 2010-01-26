# MiterBox - BoxHTML for Miter, a Graphical Ascii Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License

#require 'tomslib/lib/tomslib/rubylib'
require 'tomslib/tomslib/xmltools/prettyxml/prettyxml'

include XMLToolKit

module MiterBox

  module BoxHTML

    #
    def miter_display(*params)
      puts cut_htmlpage(*params)
    end

    # creates entire html page with stylesheet and table
    def cut_htmlpage(title, form_name, form_action, script='', append_body='')
      html = %Q{
        <html>
          <head>
            <title>#{title}</title>
            <style type="text/css">
              #{cut_htmlstylesheet}
            </style>
            <script language="JavaScript">
              #{script}
            </script>
          </head>
          <body onload="javascript: loadScript();">
            <form name="#{form_name}" action="#{form_action}" method="post">
            #{cut_html}
            </form>
            #{append_body}
          </body>
        </html>
      }
      #return html
      return PrettyXML.pretty(html, 2)
    end
    
    # creates the html table
    def cut_html
      if not @layed
        raise 'cannot build. miter not loaded. use Miter#lay first.'
      end
      return html_build_table(@main)
    end
    
    # creates the html stylesheet from @style hash
    def cut_htmlstylesheet
      @style.collect { |k, v| %Q{#{k} {#{v.collect { |k2, v2| "#{k2}: #{v2}" }.join(';')}}} if not v.empty? }.join("\n")
    end
    
    
    private  #-----------------------------------------------------------------
    
    #
    def html_build_table(table, i=nil)
      hs = ''
      table.sections.each do |section|
        if section.repeat
          repeat_length(section).times do |j|
            hs << html_build_section(section, j)
          end
        else
          hs << html_build_section(section, i)
        end
      end
      return %Q{\n<table class="#{table.class_name}">\n#{hs}</table>}
    end
    
    #
    def html_build_section(section, i=nil)
      rows = []
      rowy = nil
      hr = ''
      section.cells.each do |cell|
        hc = ''
        content = html_build_cell(cell, i)
        if content
          hc << %Q{
            <td #{%Q{class="#{cell.class_name}"} if cell.class_name}
                #{%Q{width="#{cell.width}"} if cell.width}
                #{%Q{colspan="#{cell.colspan}"} if cell.colspan > 1}
                #{%Q{rowspan="#{cell.rowspan}"} if cell.rowspan > 1}
                #{%Q{align="#{cell.alignment}"} if cell.alignment != 'left'}
            >#{content}</td>
          }
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

    #
    def html_build_cell(cell, i=nil)
      q = ''
      cell.elements.each do |element|
        if not @disable.include?(element.name)
          # build corresponding html for each element
          case element.type_name
          when 'label'
            q << apply_format(element.name.gsub(/\s/, '&nbsp;'), nil, cell.class_name)
          when 'hidden'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = apply_format(v, element.name, element.class_name)
            q << %Q{<input type="hidden"
                      #{%Q{class="#{element.class_name}"} if element.class_name}
                      name="#{element.name}"
                      value="#{v}"
                      #{html_apply_attribute(element.name, element.class_name)}
                    />
                  }
          when 'text'
            if element.size == 1
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, element.name, element.class_name)
              q << %Q{<input type="text"
                        #{%Q{class="#{element.class_name}"} if element.class_name}
                        name="#{element.name}"
                        value="#{v}"
                        #{html_apply_attribute(element.name, element.class_name)}
                      />
                    }
            else              
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, element.name, element.class_name)
              q << %Q{<textarea
                        #{%Q{class="#{element.class_name}"} if element.class_name}
                        name="#{element.name}"
                        #{html_apply_attribute(element.name, element.class_name)}
                      >#{v}</textarea>
                    }
            end
          when 'select'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = apply_format(v, element.name, element.class_name)
            q << %Q{<select
                      #{%Q{class="#{element.class_name}"} if element.class_name}
                      #{%Q{size="#{element.size}"} if element.size > 1}
                      name="#{element.name}"
                      #{html_apply_attribute(element.name, element.class_name)}
                    >
                  }
            raise "select list missing for #{element.name}" if not @cells["#{element.name}_"]
            @cells["#{element.name}_"].each do |option|
              if option.is_a?(Array)
                option_value = option[0]
                option_visible = apply_format(option[1], element.name, element.class_name)
                q << %Q{<option value="#{option_value}"
                          #{%Q{selected="true"} if option_value == "#{v}"}
                        >#{option_visible}</option>
                      }
              else
                option_value = apply_format(option, element.name, element.class_name)
                q << %Q{<option value="#{option_value}"
                          #{%Q{selected="true"} if option_value == "#{v}"}
                        >#{option_value}</option>
                      }
              end
            end
            q << %Q{</select>}
          when 'button'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = element.name if not v  # for a submit button the value will be same as the name if not given
            v = apply_format(v, element.name, element.class_name)
            button_type = 'submit'
            #button_type = 'button' if html_button_onscript?(element.name, element.class_name)
            q << %Q{<button type="#{button_type}"
                      #{%Q{class="#{element.class_name}"} if element.class_name}
                      #{%Q{name="#{element.class_name}"} if element.class_name}
                      value="#{v}"
                      #{html_apply_attribute(element.name, element.class_name)}
                    >#{element.name}</button>
                  }
          when 'radio' # and checkbox
            if element.size == 1  # check box
              v = @cells[element.name]
              v = v[i.to_i] if i
              #v = apply_format(v, element.class_name)
              q << %Q{<input type="checkbox"
                        #{%Q{class="#{element.class_name}"} if element.class_name}
                        name="#{element.name}"
                        value="#{i.to_i}"
                        #{%Q{checked="true"} if v and i.to_i == "#{v}".to_i}
                        #{html_apply_attribute(element.name, element.class_name)}
                      />
                    }
            else
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = element.name if not v  # for a radio button the value will be same as the name if not given
              v = apply_format(v, element.name, element.class_name)
              q << %Q{<input type="radio"
                        #{%Q{class="#{element.class_name}"} if element.class_name}
                        #{%Q{name="#{element.class_name}"} if element.class_name}
                        value="#{element.name}"
                        #{%Q{checked="true"} if v and element.name == v.to_s}
                        #{html_apply_attribute(element.name, element.class_name)}
                      >#{v}</input>
                    }
            end
          when 'counter'
            if element.name == 'index'
              q << "#{i}"
            else
              q << "#{i+1}"
            end
          else  # general
            # general element may be another table
            tbl = table?(element.name)
            if tbl
              q << html_build_table(tbl, i)
            else
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, nil, cell.class_name)
              q << v.to_s
            end
          end
        end
      end
      return q
    end
    
    #
    def html_apply_attribute(aname, aclass)
      attrib = get_attribute(aname, aclass)
      return attrib.collect { |k, v| %Q{#{k}="#{v}"} }.join(' ')
    end

  end  # BoxHTML

end  # MiterBox
