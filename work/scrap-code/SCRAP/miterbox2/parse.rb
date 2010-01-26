
class T

  def initialize
  
  end
  
  def me
    "Hello World!"
  end

end


tpl = %q{

<html>

  <head>
  </head>

  <body>
    <span id="me" font="courier">fill in the blank</span>
    <span id="me2">fill in the blank2</span>
  </body>

</html>
}

tt = T.new



regexp = Regexp.new(/<(\w+).*\sid="?(\w+)"?.*>(.*)<\/\1>/)

md = true
offset = 0
parsed = ''
temp = tpl.dup

while(md)
  md = regexp.match(temp)
  if md
    if tt.respond_to?(md[2].intern)
      temp[md.begin(3)...md.end(3)] = tt.send(md[2].intern)
    end
    parsed << temp[0...md.end(0)]
    offset = md.end(0)
    temp = temp[offset..-1]
  end
end
parsed << temp

puts parsed
