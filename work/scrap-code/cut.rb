#!/usr/bin/ruby

require 'getoptlong'

require 'miterbox'


if $0 == __FILE__

  opts = GetoptLong.new(
    [ "-h", "--help", GetoptLong::NO_ARGUMENT ],
    [ "-v", "--verbose", GetoptLong::NO_ARGUMENT ],
    [ "-b", "--box", GetoptLong::REQUIRED_ARGUMENT ]
  )

  opt_help = false
  opt_verbose = false
  opt_box = 'html'

  opts.each do |opt, arg|
    case opt
    when '-h'
      opt_help = true
    when '-v'
      opt_verbose = true
    when '-b'
      opt_box = arg
    end
  end

  case opt_box
  when 'html'
    require 'boxhtml'
    boxclass = MiterBox::BoxHTML
  else
    require 'boxhtml'
    boxclass = MiterBox::BoxHTML
  end

  if ARGV.length == 0
    raise 'no layout template file given'
  end
  layout_filename = ARGV[0]

  cells = {}

  cells['Button'] = 'test_action'

  cells['text'] = "E" * 200
  cells['check'] = %Q{1}
  cells['multitext'] = %Q{Multiple Lines\nEnter Here}
  cells['general'] = %Q{I've been replaced!}

  cells['listbox'] = %Q{Option A3}
  cells['listbox_'] = [ 'Option A1', 'Option A2', 'Option A3' ]
  cells['select'] = %Q{OB2}
  cells['select_'] = [ ['OB1', 'Option B1'], ['OB2', 'Option B2'], ['OB3', 'Option B3'] ]

  cells['ra'] = ['A1', 'A2', 'A3']
  cells['rb'] = ['B1', 'B2', 'B3']
  cells['rc'] = ['C1', 'C2', 'C3']

  mb = MiterBox::Miter.new(boxclass)
  #mb.set()
  mb.lay(layout_filename, cells)
  mb.miter_display('Test', 'miter-test1a.apt', 'test_action')

end
