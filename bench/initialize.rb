require 'benchmark'
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib' )))
require 'classx'

class PointWithClassX < ClassX
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

Benchmark.bm do |x|
  x.report 'classx' do
    COUNT.times do
      PointWithClassX.new({ :x => rand(10), :y => rand(10), :z => rand(10) })
    end
  end
  x.report 'normal class' do
    COUNT.times do 
      PointWithoutClassX.new({ :x => rand(10), :y => rand(10), :z => rand(10) })
    end
  end
end

# On my environment( MacBook1.1 Intel Core Duo 1.83 GHz, 2GB), result is like that. TOOOOO SLOOOW classX!!!!.
# 
# ----------------------------------------------------------
# result on 7d345a994
#                 user     system      total        real
# classx        0.350000   0.010000   0.360000 (  0.400520)
# normal class  0.000000   0.000000   0.000000 (  0.004222)
# ----------------------------------------------------------
# result on 28f399333
#                 user     system      total        real
# classx        0.380000   0.000000   0.380000 (  0.424544)
# normal class  0.000000   0.000000   0.000000 (  0.004196)
# ----------------------------------------------------------
# result on d5619b6533
#                 user     system      total        real
# classx        2.130000   0.020000   2.150000 (  2.377707)
# normal class  0.010000   0.000000   0.010000 (  0.010002)

