require 'benchmark'
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib' )))
require 'classx'

class PointWithClassX
  include ClassX
  has :x
  has :y
  has :z
end

class PointWithoutClassX
  attr_reader :x, :y, :z

  def initialize hash
    @x = hash[:x]
    @y = hash[:y]
    @z = hash[:z]
  end
end

COUNT = 1000

point_with_classx = PointWithClassX.new({ :x => 0, :y => 0, :z => 0 })
point_without_classx = PointWithoutClassX.new({ :x => 0, :y => 0, :z => 0 })

def do_bench klass
  GC.disable
  COUNT.times do
    klass.__send__ :x
    klass.__send__ :y
    klass.__send__ :z
  end
  GC.enable
end

Benchmark.benchmark '', 16, "%10.6u\t%10.6y\t%10.6t\t%10.6r\n" do |x|
  x.report 'classx', "\t%t" do
    do_bench point_with_classx
  end
  x.report 'normal class', "\t%t" do
    do_bench point_without_classx
  end
end

__END__
- 
  sha1: 0.0.7
- 
  sha1: 0.0.4
- 
  sha1: 3e97a758
- 
  sha1: 83519953e
- 
  sha1: 1f4c448b
- 
  sha1: 283903a

