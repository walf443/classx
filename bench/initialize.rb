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

Benchmark.bm do |x|
  x.report 'classx' do
    do_bench PointWithClassX
  end
  x.report 'normal class' do
    do_bench PointWithoutClassX
  end
end

# On my environment( MacBook1.1 Intel Core Duo 1.83 GHz, 2GB), result is like that. TOOOOO SLOOOW classX!!!!.
#
# ----------------------------------------------------------
# result after d85fa7de
# classx        0.070000   0.000000   0.070000 (  0.094902)
# normal class  0.010000   0.000000   0.010000 (  0.004398)
# ----------------------------------------------------------
# result after 92ed088b ( before 0.0.4 )
# classx        0.060000   0.010000   0.070000 (  0.083939)
# normal class  0.010000   0.000000   0.010000 (  0.004305)
# ----------------------------------------------------------
# result after 1f4c448b
#                 user     system      total        real
# classx        0.090000   0.010000   0.100000 (  0.093254)
# normal class  0.000000   0.000000   0.000000 (  0.004242)
# ----------------------------------------------------------
# result after a23be1ac
#                 user     system      total        real
# classx        0.100000   0.010000   0.110000 (  0.125652)
# normal class  0.000000   0.000000   0.000000 (  0.004604)
# ----------------------------------------------------------
# result after 633f7e88
#                 user     system      total        real
# classx        0.110000   0.000000   0.110000 (  0.144713)
# normal class  0.000000   0.000000   0.000000 (  0.004702)
# ----------------------------------------------------------
# result after 7d345a994
#                 user     system      total        real
# classx        0.350000   0.010000   0.360000 (  0.400520)
# normal class  0.000000   0.000000   0.000000 (  0.004222)
# ----------------------------------------------------------
# result after 28f399333
#                 user     system      total        real
# classx        0.380000   0.000000   0.380000 (  0.424544)
# normal class  0.000000   0.000000   0.000000 (  0.004196)
# ----------------------------------------------------------
# result after d5619b6533
#                 user     system      total        real
# classx        2.130000   0.020000   2.150000 (  2.377707)
# normal class  0.010000   0.000000   0.010000 (  0.010002)

