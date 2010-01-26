# MIterBox - BoxConsole for Miter, a Graphical Ascii Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License

require 'tomslib/rubylib'

module MiterBox

  module BoxConsole

    #
    def miter_display(*params)
      puts cut_consolepage(*params)
    end

    # creates entire console page with stylesheet and table
    def cut_consolepage(title, append_body='')
      text = ''
      text << %Q{\n::#{title}::\n}
      text << %Q{#{cut_console}}
      text << %Q{\n#{append_body}}
      return text
    end
    
    # creates the console table
    def cut_console
      @console_depth = ''
      if not @layed
        raise 'cannot build. miter not loaded. use Miter#lay first.'
      end
      return console_build_table(@main)
    end
    
    # creates the console stylesheet from @style hash
    #def cut_consolestylesheet
    #  @style.collect { |k, v| %Q{#{k} {#{v.collect { |k2, v2| "#{k2}: #{v2}" }.join(';')}}} if not v.empty? }.join("\n")
    #end
    
    
    private  #-----------------------------------------------------------------
    
    #
    def console_build_table(table, i=nil)
      hs = ''
      @console_depth << '|'
      table.sections.each do |section|
        if section.repeat
          repeat_length(section).times do |j|
            hs << console_build_section(section, j)
          end
        else
          hs << console_build_section(section, i)
        end
      end
      @console_depth.chomp!('|')
      q = ''
      q << @console_depth
      q << %Q{TABLE #{table.name}.#{table.class_name}\n#{hs}}
      return q
    end
    
    #
    def console_build_section(section, i=nil)
      rows = []
      rowy = nil
      hr = ''
      section.cells.each do |cell|
        hc = ''
        content = console_build_cell(cell, i)
        if content
          hc << @console_depth
          hc << %Q{CELL }
          hc << %Q{.#{cell.class_name} } if cell.class_name
          hc << %Q{(#{cell.width},#{cell.colspan},#{cell.rowspan},#{cell.alignment})\n}
          hc << %Q{#{content}}
        end
        if rowy == cell.y
          hr << hc
        else
          rows << @console_depth
          rows << "---\n"
          rows << "#{hr}" if not hr.empty?
          rowy = cell.y
          hr = hc
        end
      end
      rows << @console_depth
      rows << "---\n"
      rows << "#{hr}" #if not hr.empty?
      return rows.join # add the section rows
    end

    #
    def console_build_cell(cell, i=nil)
      q = ''
      @console_depth << '|'
      cell.elements.each do |element|
        if not @disable.include?(element.name)
          # build corresponding console for each element
          case element.type_name
          when 'label'
            q << @console_depth
            q << %Q{LABEL }
            q << apply_format(element.name, nil, cell.class_name)
            q << %Q{\n}
          when 'hidden'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = apply_format(v, element.name, element.class_name)
            q << @console_depth
            q << %Q{HIDDEN }
            q << %Q{#{element.name}#{%Q{.#{element.class_name}} if element.class_name}: }
            q << %Q{#{v}}
            q << %Q{ [#{console_apply_attribute(element.name, element.class_name)}]}
            q << %Q{\n}
          when 'text'
            if element.size == 1
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, element.name, element.class_name)
              q << @console_depth
              q << %Q{TEXT }
              q << %Q{#{element.name}#{%Q{.#{element.class_name}} if element.class_name}: }
              q << %Q{#{v}}
              q << %Q{ [#{console_apply_attribute(element.name, element.class_name)}]}
              q << %Q{\n}
            else              
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, element.name, element.class_name)
              q << @console_depth
              q << %Q{TEXT #{element.size} }
              q << %Q{#{element.name}#{%Q{.#{element.class_name}} if element.class_name}: }
              q << %Q{#{v}}
              q << %Q{ [#{console_apply_attribute(element.name, element.class_name)}]}
              q << %Q{\n}
            end
          when 'select'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = apply_format(v, element.name, element.class_name)
            q << @console_depth
            q << %Q{SELECT }
            q << %Q{#{element.name}#{%Q{.#{element.class_name}} if element.class_name}: }
            q << %Q{#{v}}
            q << %Q{[#{console_apply_attribute(element.name, element.class_name)}]}
            q << %Q{\n}
            raise "select list missing for #{element.name}" if not @cells["#{element.name}_"]
            #@cells["#{element.name}_"].each do |option|
            #  if option.is_a?(Array)
            #    option_value = option[0]
            #    option_visible = apply_format(option[1], element.name, element.class_name)
            #    q << %Q{<option value="#{option_value}"
            #              #{%Q{selected="true"} if option_value == "#{v}"}
            #            >#{option_visible}</option>
            #          }
            #  else
            #    option_value = apply_format(option, element.name, element.class_name)
            #    q << %Q{<option value="#{option_value}"
            #              #{%Q{selected="true"} if option_value == "#{v}"}
            #            >#{option_value}</option>
            #          }
            #  end
            #end
          when 'button'
            v = @cells[element.name]
            v = v[i.to_i] if i
            v = element.name if not v  # for a submit button the value will be same as the name if not given
            v = apply_format(v, element.name, element.class_name)
            button_type = 'submit'
            #button_type = 'button' if console_button_onscript?(element.name, element.class_name)
            q << @console_depth
            q << %Q{BUTTON }
            q << %Q{#{element.name}#{%Q{.#{element.class_name}} if element.class_name}: }
            q << %Q{#{v}}
            q << %Q{ [#{console_apply_attribute(element.name, element.class_name)}]}
            q << %Q{\n}
          when 'radio' # and checkbox
            if element.size == 1  # check box
              v = @cells[element.name]
              v = v[i.to_i] if i
              #v = apply_format(v, element.class_name)
              q << @console_depth
              q << %Q{RADIO X }
              q << %Q{#{element.name}#{%Q{.#{element.class_name}} if element.class_name}: }
              q << %Q{#{i.to_i} }
              if v and i.to_i == "#{v}".to_i
                q << %Q{true}
              else
                q << %Q{false}
              end
              q << %Q{ [#{console_apply_attribute(element.name, element.class_name)}]}
              q << %Q{\n}
            else
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = element.name if not v  # for a radio button the value will be same as the name if not given
              v = apply_format(v, element.name, element.class_name)
              q << @console_depth
              q << %Q{RADIO #{element.size} }
              q << %Q{#{element.name}#{%Q{.#{element.class_name}} if element.class_name}: }
              if v and element.name == "#{v}"
                q << %Q{true}
              else
                q << %Q{false}
              end
              q << %Q{ [#{console_apply_attribute(element.name, element.class_name)}]}
              q << %Q{\n}
            end
          when 'counter'
            if element.name == 'index'
              q << @console_depth
              q << %Q{COUNTER INDEX }  
              q << "#{i}"
              q << %Q{\n}
            else
              q << @console_depth
              q << %Q{COUNTER NUMBER }  
              q << "#{i+1}"
              q << %Q{\n}
            end
          else  # general
            # general element may be another table
            tbl = table?(element.name)
            if tbl
              q << console_build_table(tbl, i)
            else
              v = @cells[element.name]
              v = v[i.to_i] if i
              v = apply_format(v, nil, cell.class_name)
              q << @console_depth
              q << v.to_s
              q << %Q{\n}
            end
          end
        end
      end
      @console_depth.chomp!('|')
      return q
    end
    
    #
    def console_apply_attribute(aname, aclass)
      attrib = get_attribute(aname, aclass)
      return attrib.collect { |k, v| %Q{#{k}="#{v}"} }.join(' ')
    end

  end  # BoxConsole

end  # MiterBox

