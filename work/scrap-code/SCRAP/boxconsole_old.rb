# Jigsaw - BoxConsole for Miter, a Graphical Ascii Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License

require 'tomslib/rubylib'

module MiterBox

  module BoxConsole

    #
    def cut_console
      if not @layed
        raise 'cannot build. miter not loaded. use Miter#lay first.'
      end
      finished_product = nil
      @tables.each do |table|
        @cells[table.name] = console_build_table(table)
        finished_product = @cells[table.name]  # the last one will be our finished product
      end
      return finished_product
    end
    
    
    private  #-----------------------------------------------------------------
  
    #
    def console_build_table(table)
      hs = ''
      table.sections.each do |section|
        if section.repeat
          how_many_repeats(section).times do |i|
            hs << console_build_section(section, i)
          end
        else
          hs << console_build_section(section, nil)
        end
      end
      return hs
    end
    
    #
    def console_build_section(section, i=nil)
      rows = []
      rowy = nil
      hr = ''
      hc << %Q{#{section.class_name}.} if section.class_name
      hc << %Q{#{section.name}:\n} if section.name
      section.cells.each do |cell|
        hc = ''
        content = html_build_cell(cell, i)
        if content
          hc << %Q{#{cell.class_name}":\n} if cell.class_name
          hc << %Q{#{content}}
        end
        if rowy == cell.y
          hr << hc
        else
          rows << "#{hr}" if not hr.empty?
          rowy = cell.y
          hr = hc
        end
      end
      rows << "#{hr}" #if not hr.empty?
      return rows.join("\n") << "\n" # add the section rows
    end

    #
    def console_build_cell(cell, i=nil)
      q = ''
      cell.elements.each do |element|
        if not @disable.include?(element.name)
          case element.type_name
          when 'label'
            q << pformat(element.name.gsub(/\s/, '&nbsp;'), nil, cell.class_name)
          when 'hidden'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = pformat(v, element.name, element.class_name)
            q << %Q{<input type="hidden"}
            q << %Q{ class="#{element.class_name}"} if element.class_name
            q << %Q{ name="#{element.name}"}
            q << %Q{ value="#{v}"}
            q << ' ' << pattribute(element.name, element.class_name)
            q << %Q{/>}
          when 'text'
            if element.size == 1
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = pformat(v, element.name, element.class_name)
              q << %Q{<input type="text"}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.name}"}
              q << %Q{ value="#{v}"}
              q << ' ' << pattribute(element.name, element.class_name)
              q << %Q{/>}
            else              
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = pformat(v, element.name, element.class_name)
              q << %Q{<textarea}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.name}"}
              q << ' ' << pattribute(element.name, element.class_name)
              q << %Q{>}
              q << %Q{#{v}</textarea>}
            end
          when 'select'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = pformat(v, element.name, element.class_name)
            q << %Q{<select}
            q << %Q{ class="#{element.class_name}"} if element.class_name
            q << %Q{ size="#{element.size}"} if element.size > 1
            q << %Q{ name="#{element.name}"}
            q << ' ' << pattribute(element.name, element.class_name)
            q << %Q{>}
            raise "select list missing for #{element.name}" if not @cells["#{element.name}_"]
            @cells["#{element.name}_"].each do |option|
              if option.is_a?(Array)
                option_value = option[0]
                option_visible = pformat(option[1], element.name, element.class_name)
                q << %Q{<option value="#{option_value}"}
                q << %Q{ selected="true"} if option_value == "#{v}"
                q << %Q{>#{option_visible}</option>}
              else
                option_value = pformat(option, element.name, element.class_name)
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
            v = pformat(v, element.name, element.class_name)
            q << %Q{<button type="submit"}
            q << %Q{ class="#{element.class_name}"} if element.class_name
            q << %Q{ name="#{element.class_name}"} if element.class_name
            q << %Q{ value="#{element.name}"}
            q << ' ' << pattribute(element.name, element.class_name)
            q << %Q{>#{v}</button>}
          when 'radio' # and checkbox
            if element.size == 1  # check box
              v = @cells[element.name]
              v = v[i.to_i] if i
              #v = pformat(v, element.class_name)
              q << %Q{<input type="checkbox"}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.name}"}
              q << %Q{ value="#{i.to_i}"}
              q << %Q{ checked="true"} if v and i.to_i == "#{v}".to_i
              q << ' ' << pattribute(element.name, element.class_name)
              q << %Q{/>}
            else
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = element.name if not v  # for a radio button the value will be same as the name if not given
              v = pformat(v, element.name, element.class_name)
              q << %Q{<input type="radio"}
              q << %Q{ class="#{element.class_name}"} if element.class_name
              q << %Q{ name="#{element.class_name}"} if element.class_name
              q << %Q{ value="#{element.name}"}
              q << ' ' << pattribute(element.name, element.class_name)
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
            v = pformat(v, nil, cell.class_name)
            q << v.to_s
          end
        end
      end
      return q
    end
    
  end

end