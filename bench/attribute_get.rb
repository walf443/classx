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

Benchmark.bm do |x|
  x.report 'classx' do
    do_bench point_with_classx
  end
  x.report 'normal class' do
    do_bench point_without_classx
  end
end

# On my environment( MacBook1.1 Intel Core Duo 1.83 GHz, 2GB), result is like that. TOOOOO SLOOOW classX!!!!.
# 
# ----------------------------------------------------------
# result after 1f4c448b
#                 user     system      total        real
# classx        0.010000   0.000000   0.010000 (  0.013445)
# normal class  0.000000   0.000000   0.000000 (  0.001004)
# ----------------------------------------------------------
# result after 283903a
#                 user     system      total        real
# classx        0.020000   0.000000   0.020000 (  0.016892)
# normal class  0.000000   0.000000   0.000000 (  0.000729)
# ----------------------------------------------------------
