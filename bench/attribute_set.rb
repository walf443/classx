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

Benchmark.bm do |x|
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

# On my environment( MacBook1.1 Intel Core Duo 1.83 GHz, 2GB), result is like that. TOOOOO SLOOOW classX!!!!.
# 
# ----------------------------------------------------------
# result after 92ed088b ( before 0.0.4 )
#                                 user     system      total        real
# classx with attr_name = val   0.020000   0.010000   0.030000 (  0.029100)
# classx with attr_name(val)    0.040000   0.000000   0.040000 (  0.050599)
# normal class                  0.000000   0.000000   0.000000 (  0.002188)
# ----------------------------------------------------------
# result after 3e97a758
#                                 user     system      total        real
# classx with attr_name = val   0.020000   0.000000   0.020000 (  0.026784)
# classx with attr_name(val)    0.030000   0.010000   0.040000 (  0.051044)
# normal class                  0.010000   0.000000   0.010000 (  0.002661)
# ----------------------------------------------------------
# result after dd155598
#                                 user     system      total        real
# classx with attr_name = val   0.020000   0.000000   0.020000 (  0.020638)
# classx with attr_name(val)    0.030000   0.000000   0.030000 (  0.038159)
# normal class                  0.000000   0.000000   0.000000 (  0.002225)
# ----------------------------------------------------------
# result after 1f4c448b
#                                 user     system      total        real
# classx with attr_name = val   0.020000   0.010000   0.030000 (  0.024688)
# normal class                  0.000000   0.000000   0.000000 (  0.001821)
# ----------------------------------------------------------
# result after a23be1ac
#                                 user     system      total        real
# classx with attr_name = val   0.040000   0.000000   0.040000 (  0.038855)
# normal class                  0.000000   0.000000   0.000000 (  0.001833)
# ----------------------------------------------------------
# result after 458848f
#                                 user     system      total        real
# classx with attr_name = val   0.030000   0.010000   0.040000 (  0.051419)
# normal class                  0.000000   0.000000   0.000000 (  0.007453)
# ----------------------------------------------------------
