require 'yaml'
require 'redcloth'

# Add emitter hook
class RedCloth
    def to_yaml_type; "!hobix.com,2004/redcloth"; end
    def to_yaml( opts = {} )
        YAML::quick_emit( nil, opts ) do |out|
            out << to_yaml_type + " "
            out << self.to_s.to_yaml( :Emitter => out )
        end
    end
end

# Add loader hook
YAML.add_domain_type( "hobix.com,2004", "redcloth" ) do |type, val|
    RedCloth.new( val )
end

# Build a RedCloth string
str = RedCloth.new <<RED
h1. The Tiger's Vest (with a Basic Introduction to Irb)

!i/tigers.vest-1.gif(Tiger has vest.  Tiger likes girl robot.  Earth crashing into sun...)!

Let's install the very latest Ruby on your computer so you can follow all the examples in the (Poignant) Guide and actually do things right now!  (Yes, things!)

* If you are using *Microsoft Windows*, begin by downloading the "Ruby Installer for Windows":http://rubyforge.org/frs/?group_id=167.  Running this "one-click" installer will setup Ruby for you, as well as a tidy pack of useful software, such as a small text editor and some additional libraries.

RED

# 1. Does it output nicely?
puts str.to_yaml

# 2. does it load back in as a RedCloth object??
puts YAML::load( YAML::dump( str ) ).to_html
