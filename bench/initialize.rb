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

def do_bench klass
  GC.disable
  COUNT.times do 
    klass.new({ :x => rand(10), :y => rand(10), :z => rand(10) })
  end
  GC.enable
end

Benchmark.benchmark '', 16, "%10.6u\t%10.6y\t%10.6t\t%10.6r\n" do |x|
  x.report 'classx' do
    do_bench PointWithClassX
  end
  x.report 'normal class' do
    do_bench PointWithoutClassX
  end
end

__END__
-
  sha1: 0.0.7
-
  sha1: 0.0.6
-
  sha1: 0.0.5
-
  sha1: 0171feab
-
  sha1: d85fa7de
-
  sha1: 92ed088b
-
  sha1: 1f4c448b
-
  sha1: a23be1ac
