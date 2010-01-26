# Jigsaw - BoxTk for Miter, a Graphical Ascii Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License

require 'tomslib/rubylib'
require 'tk'

module Jigsaw

  module BoxHTML

    #
    def cut_tk
      if not @layed
        raise 'cannot build. miter not loaded. use Miter#lay first.'
      end
      finished_product = nil
      @tables.each do |table|
        @cells[table.name] = tk_build_table(table)
        finished_product = @cells[table.name]  # the last one will be our finished product
      end
      return finished_product
    end
    
    
    private  #-----------------------------------------------------------------
  
    #
    def tk_build_table(table)
      hs = ''
      table.sections.each do |section|
        if section.repeat
          repeat_length(section).times do |i|
            hs << tk_build_section(section, i)
          end
        else
          hs << tk_build_section(section, nil)
        end
      end
      return %Q{\n<table class="#{table.class_name}">\n#{hs}</table>}
    end
    
    #
    def tk_build_section(section, i=nil)
      rows = []
      rowy = nil
      hr = ''
      section.cells.each do |cell|
        hc = ''
        content = html_build_cell(cell, i)
        if content
          hc << %Q{<td}
          hc << %Q{ class="#{cell.class_name}"} if cell.class_name
          hc << %Q{ width="#{cell.width}"} if cell.width
          hc << %Q{ colspan="#{cell.colspan}"} if cell.colspan > 1
          hc << %Q{ rowspan="#{cell.rowspan}"} if cell.rowspan > 1
          hc << %Q{ align="#{cell.alignment}"}
          hc << %Q{>#{content}</td>}
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
    def tk_build_cell(cell, i=nil)
      q = ''
      cell.elements.each do |element|
        if not @disable.include?(element.name)
          #if @attributes.include?(element.name)
          #  add_attribs = @attributes[.include?(element.name)
          #end
          # build corresponding html
          case element.type_name
          when 'label'
            q << apply_format(element.name.gsub(/\s/, '&nbsp;'), nil, cell.class_name)
          when 'hidden'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = apply_format(v, element.name, element.class_name)
            q << %Q{<input type="hidden"}
            q << %Q{ class="#{element.class_name}"} if element.class_name
            q << %Q{ name="#{element.name}"}
            q << %Q{ value="#{v}"}
            q << ' ' << apply_attribute(element.name, element.class_name)
            q << %Q{/>}
          when 'text'
            if element.size == 1
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, element.name, element.class_name)
              q << %Q{<input type="text"}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.name}"}
              q << %Q{ value="#{v}"}
              q << ' ' << apply_attribute(element.name, element.class_name)
              q << %Q{/>}
            else              
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, element.name, element.class_name)
              q << %Q{<textarea}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.name}"}
              q << ' ' << apply_attribute(element.name, element.class_name)
              q << %Q{>}
              q << %Q{#{v}</textarea>}
            end
          when 'select'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = apply_format(v, element.name, element.class_name)
            q << %Q{<select}
            q << %Q{ class="#{element.class_name}"} if element.class_name
            q << %Q{ size="#{element.size}"} if element.size > 1
            q << %Q{ name="#{element.name}"}
            q << ' ' << apply_attribute(element.name, element.class_name)
            q << %Q{>}
            raise "select list missing for #{element.name}" if not @cells["#{element.name}_"]
            @cells["#{element.name}_"].each do |option|
              if option.is_a?(Array)
                option_value = option[0]
                option_visible = apply_format(option[1], element.name, element.class_name)
                q << %Q{<option value="#{option_value}"}
                q << %Q{ selected="true"} if option_value == "#{v}"
                q << %Q{>#{option_visible}</option>}
              else
                option_value = apply_format(option, element.name, element.class_name)
                q << %Q{<option value="#{option_value}"}
                q << %Q{ selected="true"} if option_value == "#{v}"
                q << %Q{>#{option_value}</option>}
              end
            end
            q << %Q{</select>}
          when 'submit'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = element.name if not v  # for a submit button the value will be same as the name if not given
            v = apply_format(v, element.name, element.class_name)
            q << %Q{<button type="submit"}
            q << %Q{ class="#{element.class_name}"} if element.class_name
            q << %Q{ name="#{element.class_name}"} if element.class_name
            q << %Q{ value="#{element.name}"}
            q << ' ' << apply_attribute(element.name, element.class_name)
            q << %Q{>#{v}</button>}
          when 'radio' # and checkbox
            if element.size == 1  # check box
              v = @cells[element.name]
              v = v[i.to_i] if i
              #v = apply_format(v, element.class_name)
              q << %Q{<input type="checkbox"}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.name}"}
              q << %Q{ value="#{i.to_i}"}
              q << %Q{ checked="true"} if v and i.to_i == "#{v}".to_i
              q << ' ' << apply_attribute(element.name, element.class_name)
              q << %Q{/>}
            else
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = element.name if not v  # for a radio button the value will be same as the name if not given
              v = apply_format(v, element.name, element.class_name)
              q << %Q{<input type="radio"}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.class_name}"} if element.class_name
              q << %Q{ value="#{element.name}"}
              q << ' ' << apply_attribute(element.name, element.class_name)
              q << %Q{>#{v}</input>}
            end
          when 'counter'
            if element.name == 'index'
              q << "#{i}"
            else
              q << "#{i+1}"
            end
          else  # general
            v = @cells[element.name]
            v = v[i.to_i] if i
            #return nil if not v
            v = apply_format(v, nil, cell.class_name)
            q << v.to_s
          end
        end
      end
      return q
    end
    
  end

end