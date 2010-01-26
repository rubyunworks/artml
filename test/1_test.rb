#!/bin/env ruby

# ARTML Test Copyright (c)2004 Thomas Sawyer

require 'test/unit'
require 'artml'
require 'succ/string/tabs'

$adapter = ARTML::Adapters::XHTML
$adapter.plugin

$yamlform = <<EOS
---
TEMPLATE: |
%s
META:
%s
STYLE:
%s
DATA:
%s
EOS

class TC_Basic < Test::Unit::TestCase

  def setup
    @t1 = %Q{+------------------+
             | "Hello World!"   |
             +------------------+}.tab(2)
    @m1 = ''
    @s1 = ''
    @d1 = ''
    
    @yarts = [ sprintf($yamlform, @t1, @m1, @s1, @d1) ]
    @model = ARTML::Model.new(*@yarts)
    @layout = @model.build
  end
  
  def test_sizes
    assert_equal(1,@model.tables.size)
    assert_equal(1,@model.tables[0].sections.size)
    assert_equal(1,@model.tables[0].sections[0].cells.size)
    assert_equal(1,@model.tables[0].sections[0].cells[0].elements.size)
  end
  
  def test_table
    assert_equal(3,@model.tables[0].lines.size)
    assert_equal('',@model.tables[0].name)
    assert_equal([],@model.tables[0].classes)
    assert_equal([],@model.tables[0].scale)  # not sure about this one yet
    assert_kind_of(Array,@model.tables[0].sections)
  end

  def test_section
    assert(! @model.tables[0].sections[0].repeat)
    assert_equal([],@model.tables[0].sections[0].scale)  # not sure about this
    assert_kind_of(Array,@model.tables[0].sections[0].cells)
  end
  
  def test_cell
    assert_equal(0,@model.tables[0].sections[0].cells[0].x)
    assert_equal(0,@model.tables[0].sections[0].cells[0].y)
    assert_equal(0,@model.tables[0].sections[0].cells[0].col)
    assert_equal(0,@model.tables[0].sections[0].cells[0].row)
    assert_equal(1,@model.tables[0].sections[0].cells[0].colspan)
    assert_equal(1,@model.tables[0].sections[0].cells[0].rowspan)
    assert_equal(nil,@model.tables[0].sections[0].cells[0].width)  #18
    assert_equal('left',@model.tables[0].sections[0].cells[0].alignment)
    assert_kind_of(Array,@model.tables[0].sections[0].cells[0].elements)
  end
  
  def test_element
    assert_kind_of(ARTML::Elements::Label,@model.tables[0].sections[0].cells[0].elements[0])
    #assert_kind_of(ARTML::Elements::Label,@model.tables[0].sections[0].cells[0].elements[0])
  end

end
