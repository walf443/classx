require 'benchmark'
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib' )))
require 'classx'

class PointWithClassX
  include ClassX
  has :x, :writable => true
  has :y, :writable => true
  has :z, :writable => true
end

class PointWithoutClassX
  attr_accessor :x, :y, :z

  def initialize hash
    @x = hash[:x]
    @y = hash[:y]
    @z = hash[:z]
  end
end

COUNT = 1000

point_with_classx = PointWithClassX.new({ :x => 0, :y => 0, :z => 0 })
point_without_classx = PointWithoutClassX.new({ :x => 0, :y => 0, :z => 0 })

def do_bench klass, style=:equal
  GC.disable
  COUNT.times do
    if style == :equal
      klass.__send__ :x=, rand(10)
      klass.__send__ :y=, rand(10)
      klass.__send__ :z=, rand(10)
    elsif style == :getter_with_arg
      klass.__send__ :x, rand(10)
      klass.__send__ :y, rand(10)
      klass.__send__ :z, rand(10)
    end
  end
  GC.enable
end

Benchmark.benchmark '', 28, "%10.6u\t%10.6y\t%10.6t\t%10.6r\n" do |x|
  x.report 'classx with attr_name = val' do
    do_bench point_with_classx
  end
  x.report 'classx with attr_name(val)' do
    do_bench point_with_classx, :getter_with_arg
  end
  x.report 'normal class' do
    do_bench point_without_classx
  end
end

__END__
- 
  sha1: 0.0.7
- 
  sha1: 3e97a758
- 
  sha1: 83519953e
- 
  sha1: 1f4c448b
- 
  sha1: 458848f
- 
  sha1: 0171feab
-
  sha1: d85fa7ded
-
  sha1: 92ed088b
-
  sha1: 3e97a758
-
  sha1: dd155598
-
  sha1: 1f4c448b
-
  sha1: a23be1ac
-
  sha1: 458848f
