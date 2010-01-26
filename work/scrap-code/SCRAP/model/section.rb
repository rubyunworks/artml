# section.rb

module ARTML

  class Section < Structure
  
    attr_reader :repeat, :cells, :scale
  
    def initialize(parent, lines, scale=[])
      super(parent, '')
      @scale = scale
      @repeat = (lines[0][0..1] == '+=' and lines[-1][0..1] == "+=")
      @cells = []
      parse(lines)
      @cells.sort!
    end
    
    # set yaml
    def to_yaml_properties
      @repeat_length = repeat_length
      return super + [ '@scale', '@repeat', '@repeat_length', '@cells' ]
    end
    def to_yaml_type
      '!!section'
    end
    
    def children; @cells; end
    
    # parse section into cells
    def parse(lines)
      
      # build character grid
      @grid = []
      lines.each do |line|
        @grid << []
        line.each_byte do |c|
          @grid.last << c.chr
        end
      end
      
      # get height and width in characters
      @width = @grid[0].length
      @height = @grid.length
    
      row = -1
      col = -1
      colspan = 1
      rowspan = 1
      row_y = -1
      @height.times do |y|
        @width.times do |x|
          if check_upperleft(x,y)  # new cell
            if row_y == y  # new column
              col += 1 + colspan - 1
            else           # new row
              row += 1
              col = 0
              row_y = y
            end
            topside, rightside, leftside, bottomside = trace(x,y)
            colspan = [topside.count('+'), bottomside.count('+')].max - 1
            rowspan = [rightside.count('+'), leftside.count('+')].max - 1
            width = calc_width(col, colspan, topside.length, @width)
            content = scan_cell(x, y, topside.length, leftside.length)
            @cells << Cell.new(self, x, y, col, row, colspan, rowspan, width, content)
          end
        end
      end
      
    end

    # calculates cell width including its colspan
    # this is mostly for the sake of html
    def calc_width(col, colspan, length, width)
      if @scale.empty?
        width = "#{100*length/width}%"
      else
        warr = @scale[col,colspan]
        if warr.length == 1
          if warr[0] == 'auto'
            return nil
          else
            return warr[0]
          end
        elsif warr.include?('auto') or warr.include?('')
          return nil  # auto is html default        
        else
          ws = 0
          apercentage = false
          afixedwidth = false
          warr.each do |w|
            ws += w.to_i
            if w[-1,1] == '%'
              apercentage = true
            else
              afixedwidth = true
            end
          end
          if apercentage and afixedwidth
            return nil  # both kinds unreconcilable
          elsif apercentage and not afixedwidth
            return "#{ws}%"
          else
            return "#{ws}"
          end
        end
      end
      return nil  # should never get here, but just in case
    end

    #
    def trace(x, y)
      # top and right
      i = 0
      j = 0
      # top side
      topside = ''
      (x...@width).each do |i|
        topside << space(i, y)
        break if check_upperright(i, y) and i != x
      end
      # right side
      rightside = ''
      (y...@height).each do |j|
        rightside << space(i, j)
        break if check_lowerright(i, j) and j != y
      end
      # left and bottom
      i = 0
      j = 0
      # left
      leftside = ''
      (y...@height).each do |j|
        leftside << space(x, j)
        break if check_lowerleft(x, j) and j != y
      end
      # bottom side
      bottomside = ''
      (x...@width).each do |i|
        bottomside << space(i, j)
        break if check_lowerright(i, j) and i != x
      end
      # all done trace
      return [topside, rightside, leftside, bottomside]
    end
    
    #
    def scan_cell(x, y, w, h)
      contains = ''
      x0 = x + 1
      y0 = y + 1
      x1 = x + w - 2
      y1 = y + h - 2
      (y0..y1).each do |j|
        contains << @grid[j][x0..x1].join
      end
      return contains
    end
    
    #
    def check_upperleft(x, y)
      (space(x,y) == '+' and space(x,y+1) == '|' and (space(x+1,y) == '-' or space(x+1,y) == '='))
    end
    
    def check_lowerleft(x, y)
      (space(x,y) == '+' and space(x,y-1) == '|' and (space(x+1,y) == '-' or space(x+1,y) == '='))
    end
    
    def check_upperright(x, y)
      (space(x,y) == '+' and space(x,y+1) == '|' and (space(x-1,y) == '-' or space(x-1,y) == '='))
    end
    
    def check_lowerright(x, y)
      (space(x,y) == '+' and space(x,y-1) == '|' and (space(x-1,y) == '-' or space(x-1,y) == '='))
    end
  
    #def check_boundry(x, y)
    #  ['+', '|', '-', '='].include?(space(x, y))
    #end
    
    #
    def space(x,y)
      return nil if x < 0
      return nil if y < 0
      return nil if x >= @width
      return nil if y >= @height
      @grid[y][x]
    end
    
    # FIX ME!!!!!!!
    def repeat_length
      cells.each do |cell|
        cell.elements.each do |element|
          if element.data['value'].is_a?(Array) #and element.type_name != 'label'
            return element.data['value'].length
          end
        end
      end
      return 0  # if no array found
    end
    
  end  # Section

end  # ARTML
