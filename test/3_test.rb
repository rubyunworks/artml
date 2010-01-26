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
             | input            |
             +------------------+}.tab(2)
    @m1 = ''
    @s1 = ''
    @d1 = %Q{|  input:
             |    value: "Hello"}.margin

    @yarts = [ sprintf($yamlform, @t1, @m1, @s1, @d1) ]
    @model = ARTML::Model.new(*@yarts)
    @layout = @model.build
  end
  
  def test_data
    assert_equal("Hello",@model.tables[0].sections[0].cells[0].elements[0].value)
  end
  
  def test_element
    assert_kind_of(ARTML::Elements::General,@model.tables[0].sections[0].cells[0].elements[0])
  end

end
