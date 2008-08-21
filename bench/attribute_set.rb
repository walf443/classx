require 'benchmark'
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib' )))
require 'classx'

class PointWithClassX < ClassX
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

Benchmark.bm do |x|
  x.report 'classx' do
    COUNT.times do
      point_with_classx.x = rand(10)
      point_with_classx.y = rand(10)
      point_with_classx.z = rand(10)
    end
  end
  x.report 'normal class' do
    COUNT.times do 
      point_without_classx.x = rand(10)
      point_without_classx.y = rand(10)
      point_without_classx.z = rand(10)
    end
  end
end

# On my environment( MacBook1.1 Intel Core Duo 1.83 GHz, 2GB), result is like that. TOOOOO SLOOOW classX!!!!.
# 
# ----------------------------------------------------------
# result after 633f7e88
#                 user     system      total        real
# classx        0.080000   0.010000   0.090000 (  0.097012)
# normal class  0.010000   0.000000   0.010000 (  0.001508)
# ----------------------------------------------------------
# result after 283903a
#                 user     system      total        real
# classx        0.810000   0.020000   0.830000 (  0.902779)
# normal class  0.000000   0.000000   0.000000 (  0.001401)
# ----------------------------------------------------------
