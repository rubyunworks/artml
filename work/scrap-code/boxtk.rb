# MiterBox - BoxTkTix for Miter, a Graphical Ascii Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License

require 'tomslib/rubylib'
require 'tk'


module MiterBox

  module BoxTk

    ALIGN2ANCHOR = {'left'=>'nw', 'right'=>'ne', 'center'=>'center'}
    DBD = 2
    DBR = 'groove'

    attr_reader :box_widgets

    #
    def miter_display(binding_object, *params)
      @binding_object = binding_object
      box_tk_cut(*params).mainloop
    end
    
    #
    def box_tk_cut
      
      if not @layed
        raise 'cannot build. miter not loaded. use Miter#lay first.'
      end
      
      @box_widgets = {}
      
      @@label_font = Tk::TkFont.new('helvetica', 'size'=>12)
      
      @@button_font = Tk::TkFont.new('system')
      @@button_font.configure('size'=>12)

      @@data_font = Tk::TkFont.new('helvetica')
      @@data_font.configure('size'=>10)

      #
      root_container = Tk::TkRoot.new

      #
      main_frame = TkCanvas.new(root_container)
      
      main_scrollbar = TkScrollbar.new(root_container) {
        command proc { |*args|
          main_frame.yview(*args)
        }
      }
      main_frame.yscrollcommand(proc { |first, last|
        main_scrollbar.set(first, last)
      })
      main_frame.pack('side'=>'left', 'anchor'=>'nw', 'fill'=>'x', 'expand'=>true)
      main_scrollbar.pack('side'=>'left', 'anchor'=>'ne', 'fill'=>'y', 'expand'=>true)
      
      #
      table_container = box_tk_build_table(main_frame, @main)
      table_container.pack('side'=>'left', 'anchor'=>'nw', 'fill'=>'x', 'expand'=>true)
      
      return root_container
      
    end
    
    # creates the tktix stylesheet from @style hash
    def box_tk_cut_stylesheet
      @style.collect { |k, v| %Q{#{k} {#{v.collect { |k2, v2| "#{k2}: #{v2}" }.join(';')}}} if not v.empty? }.join("\n")
    end
    
    
    private  #-----------------------------------------------------------------
    
    #
    def box_tk_build_table(parent, table, i=nil)
      
      table_container = Tk::TkFrame.new(parent) {
        bd DBD
        relief DBR
      }
      
      seccnt = 0
      table.sections.each do |section|
        if section.repeat
          repeat_length(section).times do |j|
            section.cells.each do |cell|
              cell_container = box_tk_build_cell(table_container, cell, j)
              cell_container.grid('row'=>cell.row+j, 'column'=>cell.col, 'rowspan'=>cell.rowspan, 'columnspan'=>cell.colspan, 'sticky'=>'snew')
            end
          end
        else
          section.cells.each do |cell|
            cell_container = box_tk_build_cell(table_container, cell, i)
            cell_container.grid('row'=>cell.row, 'column'=>cell.col, 'rowspan'=>cell.rowspan, 'columnspan'=>cell.colspan, 'sticky'=>'snew')
          end    
        end
        seccnt += 1
      end
      
      # configure column sizes (well, as best as we are able since Tk sucks!)
      table.scale.each_with_index do |c, i|
        if c == 'auto' or c[-1..-1] == '%'
          col_weight = (c.chomp('%').to_i / 10).to_i
        else
          col_weight = 1
        end
        col_minsize = c.chomp('%').to_i * 3
        TkGrid.columnconfigure(table_container, i, 'weight'=>col_weight, 'minsize'=>col_minsize)
      end
      
      return table_container
      
    end

    #
    def box_tk_build_cell(parent, cell, i=nil)
      
      cell_container = Tk::TkFrame.new(parent) {
        bd DBD
        relief DBR
      }
      
      cell.elements.each do |element|
        #
        table = table?(element.name)
        if table and element.type_name == 'general' and not @disable.include?(element.name)
          table_container = box_tk_build_table(cell_container, table, i)
          table_container.pack('side'=>'left', 'anchor'=>ALIGN2ANCHOR[cell.alignment], 'fill'=>'x', 'expand'=>true)
        elsif element.type_name != 'hidden' and not @disable.include?(element.name)
          # build corresponding tktix for each element
          case element.type_name
          when 'label'
            @box_widgets[element.name] = box_tk_build_label(cell_container, element, cell, i)
          when 'text'
            if element.size == 1
              @box_widgets[element.name] = box_tk_build_entry(cell_container, element, i)
            else
              @box_widgets[element.name] = box_tk_build_text(cell_container, element, cell, i)
            end
          when 'select'
            raise "select list missing for #{element.name}" if not @cells["#{element.name}_"]
            if element.size == 1
              @box_widgets[element.name] = box_tk_build_optionmenu(cell_container, element, i)
            else
              @box_widgets[element.name] = box_tk_build_listbox(cell_container, element, i)
            end
          when 'button'
            @box_widgets[element.name] = box_tk_build_button(cell_container, element, i)
          when 'radio' # and checkbox
            if element.size == 1  # check box
              @box_widgets[element.name] = box_tk_build_checkbox(cell_container, element, i)
            else
              @box_widgets[element.name] = box_tk_build_radio(cell_container, element, i)
            end
          when 'counter'
            @box_widgets[element.name] = box_tk_build_counter(cell_container, element, cell, i)
          else # general
            @box_widgets[element.name] = box_tk_build_general(cell_container, element, cell, i)
          end
          # pack it in
          @box_widgets[element.name].pack('side'=>'left', 'anchor'=>ALIGN2ANCHOR[cell.alignment], 'fill'=>'x', 'expand'=>true)
        end
      end
      
      return cell_container
      
    end
    
    #
    def box_tk_apply_attribute(aname, aclass)
      attrib = get_attribute(aname, aclass)
      return attrib.collect { |k, v| %Q{#{k}="#{v}"} }.join(' ')
    end


    # widget builders
    
    # GENERAL
    def box_tk_build_general(parent, element, cell, i)
    
      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      value = apply_format(value, element.name, element.class_name)
      
      # build text entry
      label = Tk::TkLabel.new(parent) {
        text value
        font @@data_font
        anchor ALIGN2ANCHOR[cell.alignment]
      }
      
      return label
      
    end
    
    # LABEL
    def box_tk_build_label(parent, element, cell, i)
    
      # get element value
      value = apply_format(element.name, nil, cell.class_name)

      # build text entry
      label = Tk::TkLabel.new(parent) {
        font('helvetica')
        text value
        anchor ALIGN2ANCHOR[cell.alignment]
      }
      
      return label
      
    end
    
    # COUNTER
    def box_tk_build_counter(parent, element, cell, i)
      
      if element.name == 'index'
        counter = Tk::TkLabel.new(cell_container) { 
          text "#{i}"
          font @@label_font
          anchor ALIGN2ANCHOR[cell.alignment]
        }
      else
        counter = Tk::TkLabel.new(cell_container) { 
          text "#{i+1}"
          font @@label_font
          anchor ALIGN2ANCHOR[cell.alignment]
        }
      end
      
      return counter
      
    end
    
    # ENTRY
    def box_tk_build_entry(parent, element, i)
    
      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      value = apply_format(value, element.name, element.class_name)
      
      # build text entry
      textentry = Tk::TkEntry.new(parent) {
        background 'white'
        font @@data_font
      }
      #textentry.insert('end', @binding_object.send("#{element.name}"))
      textentry.insert('end', value)
      #textentry.bind('<Announce>') { 
      #  textentry.insert('end', @binding_object.send("#{element.name}"))
      #}
      #textentry.bind('KeyRelease') { 
      #  @binding_object.send("#{element.name}=", textentry.value)
      #}
      
      return textentry
      
    end
    
    # TEXT
    def box_tk_build_text(parent, element, cell, i)
    
      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      value = apply_format(value, element.name, element.class_name)
      
      # build text entry
      textentry = Tk::TkText.new(parent) {
        height element.size
        background 'white'
        setgrid true
        wrap 'none'
        width cell.width.chomp('%').to_i if cell.width
      }
      textentry.font(@@data_font)
      textentry.insert('end', value)
      #textentry.bind('KeyRelease') { 
      #  @binding_object.send("#{element.name}=", textentry.value)
      #}
      
      return textentry
      
    end
    
    # LISTBOX
    def box_tk_build_listbox(parent, element, i)
    
      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      value = apply_format(value, element.name, element.class_name)
      
      # build array of options
      options = []
      @cells["#{element.name}_"].each do |option|
        if option.is_a?(Array)
          option_value = option[0]
          option_visible = apply_format(option[1], element.name, element.class_name)
          options << apply_format(option_visible, element.name, element.class_name)
        else
          option_value = apply_format(option, element.name, element.class_name)
          options << apply_format(option_value, element.name, element.class_name)
        end
      end
      
      # build listbox
      listbox = Tk::TkListbox.new(parent) {
        height element.size
        background 'white'
        font @@data_font
      }
      options.each do |option|
        listbox.insert('end', option)
      end
      
      return listbox
      
    end

    # OPTIONMENU
    def box_tk_build_optionmenu(parent, element, i)
      
      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      value = apply_format(value, element.name, element.class_name)
      
      # build array of options
      options = []
      @cells["#{element.name}_"].each do |option|
        if option.is_a?(Array)
          option_value = option[0]
          option_visible = apply_format(option[1], element.name, element.class_name)
          options << apply_format(option_visible, element.name, element.class_name)
        else
          option_value = apply_format(option, element.name, element.class_name)
          options << apply_format(option_value, element.name, element.class_name)
        end
      end

      # make bound variable
      bvar = Tk::TkVariable.new
      bvar.value = value
      
      # build dropmenu
      menubutton = Tk::TkMenubutton.new(parent) {
        textvariable bvar
        indicatoron 'on'
        relief 'sunken'
        borderwidth 2
        highlightthickness 2
        anchor 'e'
        direction 'below'
        font @@data_font
        background 'white'
      }
      menu = Tk::TkMenu.new(menubutton) {
        tearoff 'off'
      }
      menubutton.menu(menu)
      options.each do |option|
        menu.add('radio', 'label'=>option, 'variable'=>bvar)
      end
      
      return menubutton
    
    end

    # BUTTON
    def box_tk_build_button(parent, element, i)

      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      value = apply_format(value, element.name, element.class_name)
      
      # build button
      button = Tk::TkButton.new(parent) {
        text element.name
        font @@button_font
      }
      #button.command proc {
      #  @binding_object.send(value)
      #}

      return button
      
    end
    
    # CHECKBOX
    def box_tk_build_checkbox(parent, element, i)
    
      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      
      # make bound variable
      bvar = Tk::TkVariable.new
      bvar.value = value
      
      # build checkbox button
      checkbox = Tk::TkCheckbutton.new(parent) {
        variable bvar
        onvalue i ? i.to_s : '1'
        offvalue ''
      }
      checkbox.command proc { 
        @binding_object.send("#{element.name}=", bvar)
      }
      
      return checkbox
      
    end       

    # RADIO
    def box_tk_build_radio(parent, element, i)
      
      # get element value
      value = @cells[element.name]
      value = value[i.to_i] if i
      value = element.name if not value  # for a radio button the value will be same as the name if not given
      value = apply_format(value, element.name, element.class_name)
      
      # build radio button
      radio = Tk::TkRadiobutton.new(parent) {
      }

      return radio

    end
    
  end  # BoxTkTix

end  # MiterBox
