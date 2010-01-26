# blueprint.rb

require 'yaml'
require 'succ/hash/merge'
require 'succ/object'


module ARTML

  def self.prefix
    @@prefix ||= ''
  end
    
  def self.prefix=(prefix)
    @@prefix = prefix
  end

  ### ##  #####  ####   ##  #  ##    #####
  ## # #  ##  #  ##  #  ##  #  ##    ##
  ##   #  ##  #  ##  #  ##  #  ##    ###
  ##   #  #####  ####   #####  ##### #####
  ########################################
  # utils - common methods
  ########################################
  module Utils
  
    # returns the first word match
    def split_name(line)
      re = /^\s*(\w+)/
      md = re.match(line)
      return md ? md[1] : ''
    end
    
    # returns a list of all .word matches
    def split_tags(line)
      md = line.scan(/\.(\w+)\s*?/)
      md ? md.flatten : []
    end
  
    # add a prefix if name starts with ^
    # bug? b/c name is just word characters
    def fix_name(name)
      if name[0,1] == '^'
        return "#{ARTML.prefix}#{name[1..-1].strip}"
      else
        return name.strip
      end
    end
    
  end  # Utils
  
  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #########################################
  # blueprint - unified composition object
  #########################################
  class Blueprint
    include Utils

    ### these are the various parts of a composition

    # layout
    ::YAML.add_domain_type( "artml.rubyforge.org,2004", "layout" ) { |type, val| 
      def val.tag; '!!layout'; end; val 
    }
    ::YAML.add_private_type( "layout" ) { |type, val| val }
    
    # components
    ::YAML.add_domain_type( "artml.rubyforge.org,2004", "components" ) { |type, val| 
      def val.tag; '!!components'; end; val 
    }
    ::YAML.add_private_type( "components" ) { |type, val| val }  
    
    # style
    ::YAML.add_domain_type( "artml.rubyforge.org,2004", "stylesheet" ) { |type, val|
      def val.tag; '!!stylesheet'; end; val 
    }
    ::YAML.add_private_type( "stylesheet" ) { |type, val| val }
    
    #::YAML.add_private_type( "blueprint" ) { |t, v| Model.import( v['tables'], v['main'], v['metadata'] ) }
    
    # CLASS METHODS
    class << self
      def import( tables=[], main=nil, metadata = {} )
        m = self.new
        m.tables = tables
        m.main = main
        m.metadata = metadata
        m
      end
    end
    
    def to_yaml_type; '!!form'; end
    def to_yaml_properties
      [ '@tables', '@main', '@metadata', '@style' ]
    end

    attr_accessor :layout, :style, :components
    attr_reader :art, :style, :data
    
    attr_reader :tables, :main, :metadata
    
    def model; self; end    
    def children; @tables; end
    
    # *
    def initialize(*yio)
      @layout = ''
      @style = {}
      @components = {}
      add(*yio)
      raise "no layout" if @layout.empty? # =~ /\A\s*\Z/
    end
    
    def add( *yio )
      yio.each do | y |
        YAML::load_documents( y ) do |doc|
          add_copy( doc )
        end
      end
    end
    
    def add_copy( c )
      case c.tag
        when '!!layout'; @layout += "\n#{c}"
        when '!!stylesheet'; @style += c
        when '!!components'; @components += c
        else; raise("undefined part: \n #{c}")
      end
    end
    
    # constructicon           
    def construct
      @art = @layout
      @style = @style
      @data = @components
      @metadata = @components['meta'] || {}
      #---
      @tables = []
      @main = nil
      parse
      # return the model
      self.to_yaml
    end

    # parse routine breaks down a things down into tables
    def parse
      return if @art.strip == ''
      
      # external substitutions
      #@art = external_sub(@layout)
      
      lines = @art.split("\n").collect { |line| line.strip }   # split layout into lines array
      lines.reverse!  # work backwards
      lines << ''     # pad one line
      
      # start
      table_remarks = []
      table_name = ''
      table_tags = []
      table_lines = []
      table_scale = ''
      mark = false
      ontable = false
      
      lines.each do |line|          # loop through each line
        if line =~ /^[\+\|]/         # if line is a table construct
          if line =~ /[-=]{3,}/       # if it is a row line
            table_lines << line
          else
            table_lines << line
          end
          ontable = true
        elsif line[0..0] == '!'     # if line is a table scale
          table_scale = line
          ontable = true
        elsif line[0..0] == '#'     # if line is a remark
          table_remarks << line
        elsif line == ''            # if line is blank
          #mark = true if ontable
          ontable = false
        else                        # hit a table header: title .class ...
          table_name = split_name(line)
          table_tags += split_tags(line)
          mark = true
          ontable = false
        end
        if mark and !ontable
          @tables << Table.new( self, table_lines.reverse, table_name, table_tags, table_scale, table_remarks )
          # reset
          table_remarks = []
          table_name = ''
          table_tags = []
          table_lines = []
          table_scale = ''
          mark = false
        end
      end
      @main = @tables.last
      raise "no main table" unless @main
      @main.form = true unless @main.tags.include?('table')
    end
    
    # external subtitutions
    # not currently being used
    def external_sub(layout)
      layout.gsub!(/&.+$/) do |match|
        sublayout_file = match[1..-1].strip
        if is_relative?(sublayout_file)
          sublayout_file = "#{@layout_path}/#{sublayout_url}"
        end
        sublayout_file = File.expand_path(sublayout_file)
        sublayout = ''
        File.open(sublayout_file) { |f| sublayout << f.read }
        external_sub(sublayout << "\n")
      end
      return layout
    end
    
    #
    def table?(table_name)
      @tables.detect { |tbl| tbl.name == table_name }
    end

    #
    def preprint
      { 'layout' => @layout, 
        'components' => @components,
        'style' =>  @style
      }.to_yaml
      #@metadata = @components['metadata'] || {}
    end
    
  end  # Model

  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #####################################################
  # structure - base class for most parts of the model
  #####################################################
  class Structure
    
    include Utils
  
    attr_reader :parent, :model
    attr_accessor :name, :tags
    attr_reader :style, :data
    
    def initialize( parent, name=nil, tags=[] )
      # set parent and model
      @parent = parent
      @model = parent.model
      @name = name
      @tags = tags
      style_set
      #data_set
    end
    
    # set yaml
    def to_yaml_properties
      @tag = tag()
      [ '@name', '@tag', '@tags', '@style', '@tag_style' ]
    end
    def to_yaml_type
      '!!structure'
    end
    
    def style_set
      @style = {}
      @style.update( self.model.style[@name] ) if self.model.style.has_key?(@name)
      @tag_style = {}
      @tags.each {|t| @tag_style.update(self.model.style[".#{t}"]) if self.model.style.has_key?(".#{t}") } if @tags
      return @style, @tag_style
    end
    
    #def style_set
    #  @style = {}
    #  @tags.each { |t| @style.update(self.model.style[t]) if self.model.style.has_key?(t) } if @tags
    #  @style.update( self.model.style[@name] ) if self.model.style.has_key?( @name )
    #  @style
    #end
    
#     def data_set
#       @data = {}
#       @tags.each {|t| @data.update( self.model.data[t] ) if self.model.data.has_key?( t ) } if @tags
#       if self.model.data.has_key?( @name )
#         c = self.model.data[@name]
#         if self.model.data[@name].kind_of?(Hash)
#           @data.update( self.model.data[@name] )
#         else
#           @data['value'] = self.model.data[@name]
#         end
#       end
#       @data
#     end
    
    def tag
      tags[0]
    end
    
    def tag=( x )
      tags.unshift( x )
    end
    
  end  # Structure

  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #####################################################
  # table - a model consits of one or more tables 
  #####################################################
  class Table < Structure
   
    DIVLINE = /^[+=-]+$/
  
    attr_reader :lines, :scale, :remarks, :sections
    attr_accessor :form
  
    def children; @sections; end
    
    def initialize( parent, lines, name='', tags=[], scale='', remarks=[] )
      @lines = lines
      @scale = { 'literal' => scale.strip }
      #@scale = scale.strip.split('!').collect {|s| s.strip.empty? ? 'auto' : s.strip.downcase }[1..-1]
      #@scale = [] if not @scale
      @form = tags.include?('form')
      @sections = []
      super( parent, name, tags )
      data_set
      parse(lines)
    end
    
    # set yaml
    def to_yaml_properties
      super + [ '@tab_sets', '@scale', '@form', '@data', '@sections' ]
    end
    def to_yaml_type; '!!table'; end
    
    def parse(lines)
      # determine tabsets and cascade '+' throughout
      divlines = []
      tab_sets = []
      lines.each_with_index do |line, i|
        if line =~ DIVLINE
          divlines << i
          j = -1
          while j
            j = line.index('+',j+1)
            tab_sets << j if ! tab_sets.include?(j) if j
          end
        end
      end
      tab_sets.sort!
      divlines.each {|i| tab_sets.each {|t| lines[i][t..t] = '+'} }
      @tabsets = tab_sets
      # determine scales
      j = -1; scale_tabsets = []
      while j
        j = @scale['literal'].index('!',j+1)
        scale_tabsets << j if j
      end
      if scale_tabsets.empty?
        @scale['tabsets'] = []
        @scale['widths'] = []
        @scale['ranges'] = []
      else
        scale_tabsets.sort!
        raise "scale is not in line with columns" if scale_tabsets.any? {|ss| ! tab_sets.include?(ss)}
        scale_widths = @scale['literal'].split('!').collect {|s| s.strip.empty? ? 'auto' : s.strip.downcase }[1..-1]
        scale_ranges = []; cstart = 0
        scale_tabsets[1..-1].each{|s|
          i = tab_sets.index(s)
          scale_ranges += [cstart..i-1]
          cstart = i
        }
        @scale['tabsets'] = scale_tabsets
        @scale['widths'] = scale_widths
        @scale['ranges'] = scale_ranges
      end
      # divide up into sections
      section_lines = []
      lines.each { |line|
        if not section_lines.empty? and line[0..1] == '+='
          section_lines << line
          @sections << Section.new(self, section_lines, @scale)
          section_lines = [line]
        else
          section_lines << line
        end
      }
      # finish off last section
      if not section_lines.empty? 
        @sections << Section.new(self, section_lines, @scale)
      end
    end

    def data_set
      @data = {}
      @tags.each {|t| @data.update( self.model.data[t] ) if self.model.data.has_key?( t ) } if @tags
      if self.model.data.has_key?( @name )
        c = self.model.data[@name]
        if self.model.data[@name].kind_of?(Hash)
          @data.update( self.model.data[@name] )
        else
          @data['value'] = self.model.data[@name]
        end
      end
      @data
    end
        
  end  # Table

  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #####################################################
  # section - a table may have one or more sections
  # sections are repeatable row groupings
  #####################################################
  class Section < Structure
  
    attr_reader :repeat, :cells, :scale
  
    def children; @cells; end
    
    def initialize(parent, lines, scale)
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
      super + [ '@scale', '@repeat', '@repeat_length', '@cells' ]
    end
    def to_yaml_type; '!!section'; end
    
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

    # calculates cell width
    # this is mostly for the sake of html
    def calc_width(col, colspan, length, width)
      if @scale['tabsets'].empty?
        cwidth = "#{100*length/width}%"
      else
        i = nil
        @scale['ranges'].each_with_index {|r, j|
          if r === col
            i = j; break
          end
        }
        if i
          w = @scale['widths'][i]
          r = @scale['ranges'][i]
          if r.to_a.length == colspan
            cwidth = w
          elsif r.to_a.length > colspan
            wint = w.to_i / (r.to_a.length / colspan)
            cwidth = wint.to_s + w[(w.index(/[A-Za-z]/))..-1]
          else  # too complicated a scenario? THINK ABOUT!!!
            cwidth = nil  # html defaults to 'auto'
          end
        else
          cwidth = nil
        end
      end
          
#         warr = @scale[col,colspan]
#         if warr.length == 1
#           if warr[0] == 'auto'
#             return nil
#           else
#             return warr[0]
#           end
#         elsif warr.include?('auto') or warr.include?('')
#           return nil  # auto is html default        
#         else
#           ws = 0
#           apercentage = false
#           afixedwidth = false
#           warr.each do |w|
#             ws += w.to_i
#             if w[-1,1] == '%'
#               apercentage = true
#             else
#               afixedwidth = true
#             end
#           end
#           if apercentage and afixedwidth
#             return nil  # both kinds unreconcilable
#           elsif apercentage and not afixedwidth
#             return "#{ws}%"
#           else
#             return "#{ws}"
#           end
#         end
#       end
      return cwidth
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
          if element.respond_to?(:value) and element.value.is_a?(Array) #and element.type_name != 'label'
            return element.value.length
          end
        end
      end
      return 0  # if no array found
    end
    
  end  # Section

  
   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #####################################################
  # cell - every little box
  #####################################################
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
        @elements << ARTML::Element.new(self, literal_element)
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
  
  
  ### ##  #####  ####   ##  #  ##    #####
  ## # #  ##  #  ##  #  ##  #  ##    ##
  ##   #  ##  #  ##  #  ##  #  ##    ###
  ##   #  #####  ####   #####  ##### #####
  ########################################
  # element factory
  ########################################
  #module ElementFactory
  #  def self.new( parent, literal )
  #    e = STD_ELEMENTS[literal[0..0]] || STD_ELEMENTS[nil]
  #    c = instance_eval "Elements::#{e}"
  #    c.new( parent, literal )
  #  end
  #end
 

   ####  ##     ###   #####  #####
  ##     ##    ##  #  ###    ###
  ##     ##    #####    ###    ###
   ####  ##### ##  #  #####  #####
  #####################################################
  # element - base class for all elements  
  #####################################################
  class Element
    include Utils
    attr_reader :parent, :model
    attr_accessor :name, :tag, :tags
    attr_reader  :literal, :size, :style, :value
    
    def initialize( parent, literal )
      raise "empty literal" if literal.empty?
      @parent = parent
      @model = parent.model
      @literal = literal.strip
      
      # set tag
      @tag = '!!' << (STD_COMPONENTS[@literal[0..0]] || STD_COMPONENTS[nil])
      
      # set size
      @size = 0
      if literal[0..0] !~ /\w/
        if literal[0..0] =~ /[\[{(<]/
          @size = literal.count(literal[0..0])
        else
          @size = literal.count(literal[0..0]) / 2
        end
      end
    
      @name = split_name(literal[@size..-(@size+1)])
      @tags = split_tags(literal[@size..-(@size+1)])
      
      @value = nil
      
      style_set
      components_set
    end
    
    def to_yaml_properties
      kl = self.instance_variables - [ '@parent', '@model', '@tag' ]
    end
    def to_yaml_type; @tag; end
  
    def style_set
      @style = {}
      @style.update( self.model.style[@name] ) if self.model.style.has_key?(@name)
      @tag_style = {}
      @tags.each { |t| @tag_style.update(self.model.style[t]) if self.model.style.has_key?(t) } if @tags
      return @style, @tag_style
    end
    
    def components_set
      
      #@data = {}
      # data for tags? how to handle ?
      #@tags.each {|t| @data.update( self.model.data[t] ) if self.model.data.has_key?( t ) } if @tags
      
      if self.model.data.has_key?( @name )
        c = self.model.data[@name]
        if c.kind_of?(Component)
          @tag = c.tag if @tag == '!!general'
          if @tag != c.tag
            raise "type mismatch between layout and components: #{@tag} != #{c.tag}"
          end
          with_readers(c.data)
        elsif c.kind_of?(Hash)
          #@data.update( self.model.data[@name] )
          set_instances( c )
        else
          @value = c
        end
      end
    end
    
    #def tag
    #  tags[0]
    #end
    #def tag=( x )
    #  tags.unshift( x )
    #end

  end

  
  # CONSTANT
  ##########################
  # element symbol mapping
  ##########################
  STD_COMPONENTS = { 
      nil => 'general',
      "'" => 'label',
      '"' => 'markup',
      '*' => 'hidden',
      '[' => 'field',
      '<' => 'button',
      '{' => 'selector',
      '(' => 'radio',
      '#' => 'counter'
  }
  
  STD_COMPONENTS.each_value{ |e|
    YAML.add_private_type(e.to_s.downcase){ |type, val| Component.new(type, val) }
  }

  class Component
    attr_accessor :tag, :data
    #def initialize( parent, literal ); super; end
    def initialize(tag, data)
      @tag = '!!' << tag.split(':').last
      @data = data
    end
    def to_yaml_type
      @tag
    end
  end

  ### ##  #####  ####   ##  #  ##    #####
  ## # #  ##  #  ##  #  ##  #  ##    ##
  ##   #  ##  #  ##  #  ##  #  ##    ###
  ##   #  #####  ####   #####  ##### #####
  ########################################
  # standard elements
  ########################################
  #module Elements
  #  STD_ELEMENTS.values.each do |e|
  #    class_eval <<-EOS
  #      class #{e} <  Element
  #        def initialize( parent, literal ); super; end
  #        def to_yaml_type; '!!#{e.to_s.downcase}'; end
  #      end
  #    EOS
  #  end    
  #end  # Elements

end  # ARTML
