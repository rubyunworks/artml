#!/usr/bin/env ruby

# ARTML Test Copyright (c)2004 Thomas Sawyer

require 'artml'

if $0 == __FILE__

  art_files = ARGV
  y = art_files.collect { |f| File.new(f) }
  
  #puts ARTML.load(:xhtml, *arts)
  
  b = ARTML::Blueprint.new( *y ).construct
  #puts b 
  a = ARTML::Adapter.new(:xhtml)
  r = a << b
  puts r
    
end


  #cells = {}

  #cells['Button'] = 'test_action'

  #cells['text'] = "E" * 200
  #cells['check'] = %Q{1}
  #cells['multitext'] = %Q{Multiple Lines\nEnter Here}
  #cells['general'] = %Q{I've been replaced!}

  #cells['listbox'] = %Q{Option A3}
  #cells['listbox_'] = [ 'Option A1', 'Option A2', 'Option A3' ]
  #cells['select'] = %Q{OB2}
  #cells['select_'] = [ ['OB1', 'Option B1'], ['OB2', 'Option B2'], ['OB3', 'Option B3'] ]

  #cells['ra'] = ['A1', 'A2', 'A3']
  #cells['rb'] = ['B1', 'B2', 'B3']
  #cells['rc'] = ['C1', 'C2', 'C3']
