#!/usr/local/bin/ruby

require 'Tix'

########################
# �ƥ���
TixDirList.new(nil).pack
TixFileEntry.new(nil, 'label' => 'FILE').pack
TkButton.new(nil, 
	     'text' => 'hello',
	     'command' => proc{print "hello\n"}).pack('fill'=>'x')
TkButton.new(nil,
	     'text' => 'quit',
	     'command' => 'exit').pack('fill'=>'x')
Tk.mainloop
