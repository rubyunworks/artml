# MiterBox - Miterize, a Graphical Ascii Form and Table Template Tool
# Copyright (c) 2002 Thomas Sawyer, Ruby License

require 'miterbox/miter'

module MiterBox

  module Miterize
    
    def miter_display(box, *params)
      @miter = Miter.new(box)
      @miter.set(miter_formats, miter_attributes, miter_style)
      @miter.lay(miter_layout, miter_assignment, '', miter_disable)
      @miter.miter_display(self, *params)
    end
    
    def miter_widgets
      @miter.box_widgets
    end
    
  end  # Miterize
  
  
  # The Miter Widgets
  #
  # these are the variable/object extention modules
  # they link a variable/object to its associated widget
  # to use:
  #
  #    vobj.extend MiterWidget
  #
  
  module ListBox
  
    def push(arr)
      @box_widgets[self.id].box_list_push(arr)
      super
    end
  
    def <<(arr)  # do not need in box
      @box_widgets[self.id].box_list_push(arr)
      super
    end
    
    def pop(arr)
      @box_widgets[self.id].box_list_pop(arr)
      super
    end
    
    def[]=(arrORarroarr)
      @box_widgets[self.id].box_list_adjust(arrORarroarr)
      super
    end
    
    def clear
      @box_widgets[self.id].box_list_clear
      super
    end
    
    def collect!(&block)
      @box_widgets[self.id].box_list_collect!(&block)
      super
    end
    
    def compact!  # remove
    end
    
    def concat(arrofarr)
      @box_widgets[self.id].box_list_concat(arroarr)
      super
    end
    
    def delete
    
    end
    
    def delete_at
    
    end
    
    def fill
    
    end
    
    def flatten!  # remove
    end
    
    def map!(&block)  # do not need in box
      @box_widgets[self.id].box_list_collect!(&block)
      super
    end 
    
    def replace
    
    end
    
    def reverse!
    
    end
    
    def shift
    
    end
    
    def slice!
    
    end
    
  end
  
  
  module ColumnListBox
  
    def push(arr)
      @box_widgets[self.id].box_columnlist_push(arr)
      super
    end
  
    def <<(arr)  # do not need in box
      @box_widgets[self.id].box_columnlist_push(arr)
      super
    end
    
    def pop(arr)
      @box_widgets[self.id].box_columnlist_pop(arr)
      super
    end
    
    def[]=(arrORarroarr)
      @box_widgets[self.id].box_columnlist_adjust(arrORarroarr)
      super
    end
    
    def clear
      @box_widgets[self.id].box_columnlist_clear
      super
    end
    
    def collect!(&block)
      @box_widgets[self.id].box_columnlist_collect!(&block)
      super
    end
    
    def compact!  # remove
    end
    
    def concat(arrofarr)
      @box_widgets[self.id].box_columnlist_concat(arroarr)
      super
    end
    
    def delete
    
    end
    
    def delete_at
    
    end
    
    def fill
    
    end
    
    def flatten!  # remove
    end
    
    def map!(&block)  # do not need in box
      @box_widgets[self.id].box_columnlist_collect!(&block)
      super
    end 
    
    def replace
    
    end
    
    def reverse!
    
    end
    
    def shift
    
    end
    
    def slice!
    
    end
    
  end
  
  
  
  
end  # MiterBox

