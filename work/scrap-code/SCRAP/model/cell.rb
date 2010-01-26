# cell.rb

module ARTML

  class Cell < Structure
  
    TOKENS = { '<'=>'>', '['=>']', '{'=>'}', '('=>')', '&'=>'&', '*'=>'*', '#'=>'#', '"'=>'"', "'"=>"'"}
  
    attr_accessor :x, :y, :col, :row, :colspan, :rowspan, :width
    attr_accessor :alignment, :elements, :content
  
    def initialize(parent, x, y, col, row, colspan, rowspan, width, content)
      @x = x
      @y = y
      @col = col
      @row = row
      @colspan = colspan
      @rowspan = rowspan
      @width = width
      @tags = []
      @alignment = 'left'
      @content = content
      @elements = []
      name = split_name(content)
      name = name.empty? ? "cell #{row} #{col}" : name
      tags = split_tags(content)
      super(parent, name, tags) 
      parse(content)
      #style_ref_set  # set any styles from refrences like 'child/cell'
    end
    
    # set yaml
    def to_yaml_properties
      super + [ '@x', '@y', '@col', '@row', '@colspan', '@rowspan', '@width', '@alignment', '@content', '@elements' ]
    end
    def to_yaml_type
      '!!cell'
    end
    
    def children; @elements; end
    
    # parse out the alignment and tags
    def parse(content)
      # alignment
      left_margin = 9999
      right_margin = 9999
      content.split("\n").each { |ln|
        spaces = (/^\s*/.match(ln) || [])[0].length
        left_margin = spaces if spaces < left_margin
        spaces = (/\s*$/.match(ln) || [])[0].length
        right_margin = spaces if spaces < right_margin
      }
      case (left_margin / 2.0).round <=> (right_margin.to_f / 2.0).round
      when 1
        @alignment = 'right'
      when -1
        @alignment = 'left'
      else
        @alignment = 'center'
      end
      # get the tags out
      content_copy = content.dup
      @tags.each { |k| content_copy.gsub!(".#{k}", '') }
      content_copy.strip!
      # parse the elements
      symbols_array = tokenizer(content_copy)
      symbols_array.each do |literal_element|
        @elements << ARTML::ElementFactory.new(self, literal_element)
      end
    end

    # (special thanks to sean russell)
    def tokenizer(string)
      items = []
      while string.size > 0
        if TOKENS.keys.include?(string[0,1])
          end_index = string.index(TOKENS[string[0,1]], 1)
          raise "bad end_index for #{string}" if not end_index
          item = string[0..end_index]
          items << item
          string = string[end_index+1..-1]
          while item.count(item[0,1]) > item.count(TOKENS[item[0,1]])
            end_index = string.index(TOKENS[item[0,1]])
            item << string[0..end_index]
            string = string[end_index+1..-1]
          end
        else
          end_index = string.index(/([\[({<&*#"'^\s]|\z)/, 1)
          item = string[0..end_index-1].strip
          items << item if not item.empty?
          string = string[end_index..-1]
        end
      end
      items
    end
    
    #
    def <=>(b)
      if self.y < b.y
        return -1
      elsif self.y == b.y and self.x < b.x
        return -1
      elsif self.y == b.y and self.x == b.x
        return 0
      else
        return 1
      end  
    end
  
#     def style_ref_set
#       children.each { |c|
#         if model.style.has_key?("#{c.name}/cell")
#           @style.update( model.style["#{c.name}/cell"] )
#         end
#       }
#     end
    
  end  # Cell

end  # ARTML

