require 'benchmark'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'classx'

include ClassX::Declare

def count_times_define &block
  GC.disable
  attr_name = 'a'
  COUNT.times do
    block.call(attr_name)
    attr_name = attr_name.succ
  end
  GC.enable
end

COUNT = 1000
Benchmark.benchmark '', 24, "%10.6u\t%10.6y\t%10.6t\t%10.6r\n" do |x|
  x.report "attr_reader" do
    class SimpleDefine
      include ClassX

      count_times_define do |name|
        attr_reader name
      end
    end
  end
  x.report "simple define" do
    class SimpleDefine
      include ClassX

      count_times_define do |name|
        has name
      end
    end
  end
  x.report "with declare" do
    classx "WithDeclare" do
      count_times_define do |name|
        has name
      end
    end
  end
  x.report "with writable" do
    class WithWritable
      include ClassX

      count_times_define do |name|
        has name, :writable => true
      end
    end
  end

  x.report "with optional" do
    class WithOptional 
      include ClassX

      count_times_define do |name|
        has name, :optional => true
      end
    end
  end

  x.report "with default" do
    class WithDefault
      include ClassX

      count_times_define do |name|
        has name, :default => name
      end
    end
  end

  x.report "with default Proc" do
    class WithDefaultProc
      include ClassX

      count_times_define do |name|
        has name, :default => proc {|mine| name }
      end
    end
  end

  x.report "with default Proc lazy" do
    class WithDefaultProcLazy
      include ClassX

      count_times_define do |name|
        has name, :lazy => true, :default => proc {|mine| name }
      end
    end
  end
  x.report "with validate Proc" do
    class WithValidateProc
      include ClassX
      
      count_times_define do |name|
        has name, :validate => proc { true }
      end
    end
  end

  x.report "with validate Regexp" do
    class WithValidateRegexp
      include ClassX
      
      count_times_define do |name|
        has name, :validate => /hoge/
      end
    end
  end

  x.report "with handles Array" do
    class WithHandlesArray
      include ClassX

      count_times_define do |name|
        has name, :handles => [ "#{name}_foo", ]
      end
    end
  end

  x.report "with handles Hash" do
    class WithHandlesHash
      include ClassX

      count_times_define do |name|
        has name, :handles => { "#{name}_foo" => "foo", }
      end
    end
  end
  x.report "with include" do
    class WithInclude
      include ClassX

      mod = Module.new
      count_times_define do |name|
        has name, :include => mod
      end
    end
  end

  x.report "with extend" do
    class WithExtend
      include ClassX

      mod = Module.new
      count_times_define do |name|
        has name, :extend => mod
      end
    end
  end
end

# On my environment( MacBook1.1 Intel Core Duo 1.83 GHz, 2GB), result is like that. TOOOOO SLOOOW classX!!!!.
# 
# ----------------------------------------------------------
# result after ad6a1e8be27
#                             user     system      total        real
# attr_reader               0.010000   0.000000   0.010000 (  0.009723)
# simple define             0.220000   0.010000   0.230000 (  0.284162)
# with declare              0.230000   0.020000   0.250000 (  0.296754)
# with writable             0.180000   0.020000   0.200000 (  0.216788)
# with optional             0.260000   0.020000   0.280000 (  0.296184)
# with default              0.200000   0.010000   0.210000 (  0.234367)
# with default Proc         0.270000   0.020000   0.290000 (  0.321229)
# with default Proc lazy    0.210000   0.010000   0.220000 (  0.238869)
# with validate Proc        0.310000   0.030000   0.340000 (  0.358173)
# with validate Regexp      0.200000   0.010000   0.210000 (  0.236095)
# with handles Array        0.240000   0.020000   0.260000 (  0.278163)
# with handles Hash         0.380000   0.020000   0.400000 (  0.433075)
# with include              0.210000   0.010000   0.220000 (  0.237816)
# with extend               0.200000   0.020000   0.220000 (  0.246489)
# ----------------------------------------------------------
# result after 92ed088b ( before 0.0.4 )
#                             user     system      total        real
# attr_reader               0.010000   0.000000   0.010000 (  0.011373)
# simple define             0.190000   0.020000   0.210000 (  0.245375)
# with declare              0.210000   0.020000   0.230000 (  0.269984)
# with writable             0.170000   0.020000   0.190000 (  0.198645)
# with optional             0.230000   0.020000   0.250000 (  0.265170)
# with default              0.170000   0.010000   0.180000 (  0.190290)
# with default Proc         0.240000   0.020000   0.260000 (  0.271484)
# with default Proc lazy    0.180000   0.010000   0.190000 (  0.204015)
# with validate Proc        0.290000   0.030000   0.320000 (  0.317159)
# with validate Regexp      0.170000   0.010000   0.180000 (  0.201919)
# with handles Array        0.330000   0.020000   0.350000 (  0.352262)
# with handles Hash         0.210000   0.020000   0.230000 (  0.233292)
# with include              0.320000   0.020000   0.340000 (  0.353505)
# with extend               0.190000   0.010000   0.200000 (  0.218557)
# ----------------------------------------------------------
# result after dd1bb608
#                             user     system      total        real
# attr_reader               0.010000   0.000000   0.010000 (  0.011491)
# simple define             0.190000   0.020000   0.210000 (  0.244600)
# with declare              0.210000   0.020000   0.230000 (  0.275477)
# with writable             0.160000   0.010000   0.170000 (  0.182082)
# with optional             0.240000   0.020000   0.260000 (  0.259744)
# with default              0.180000   0.020000   0.200000 (  0.205924)
# with default Proc         0.250000   0.010000   0.260000 (  0.281318)
# with default Proc lazy    0.170000   0.020000   0.190000 (  0.193371)
# with validate Proc        0.270000   0.020000   0.290000 (  0.327297)
# with validate Regexp      0.170000   0.010000   0.180000 (  0.203348)
# with handles Array        0.300000   0.020000   0.320000 (  0.343018)
# with handles Hash         0.200000   0.020000   0.220000 (  0.227186)
# with include              0.320000   0.020000   0.340000 (  0.345723)
# with extend               0.190000   0.010000   0.200000 (  0.212512)
# ----------------------------------------------------------
# result after 29a8e329
#                             user     system      total        real
# attr_reader               0.010000   0.010000   0.020000 (  0.011874)
# simple define             0.200000   0.010000   0.210000 (  0.239444)
# with declare              0.210000   0.020000   0.230000 (  0.264705)
# with writable             0.180000   0.020000   0.200000 (  0.210539)
# with optional             0.230000   0.010000   0.240000 (  0.255122)
# with default              0.190000   0.020000   0.210000 (  0.206571)
# with default Proc         0.240000   0.020000   0.260000 (  0.263485)
# with default Proc lazy    0.200000   0.010000   0.210000 (  0.224858)
# with validate Proc        0.300000   0.020000   0.320000 (  0.309174)
# with validate Regexp      0.180000   0.010000   0.190000 (  0.213703)
# with handles Array        0.340000   0.030000   0.370000 (  0.364112)
# with handles Hash         0.200000   0.020000   0.220000 (  0.227948)
# with include              0.340000   0.010000   0.350000 (  0.357848)
# with extend               0.210000   0.020000   0.230000 (  0.223762)
# ----------------------------------------------------------
# result after 1f4c448b
#                           user     system      total        real
#                             user     system      total        real
# attr_reader               0.010000   0.000000   0.010000 (  0.010592)
# simple define             0.340000   0.060000   0.400000 (  0.394536)
# with declare              0.380000   0.060000   0.440000 (  0.457872)
# with writable             0.310000   0.050000   0.360000 (  0.361601)
# with optional             0.410000   0.060000   0.470000 (  0.482068)
# with default              0.290000   0.040000   0.330000 (  0.347324)
# with default Proc         0.430000   0.060000   0.490000 (  0.492673)
# with default Proc lazy    0.290000   0.050000   0.340000 (  0.351080)
# with validate Proc        0.470000   0.060000   0.530000 (  0.542845)
# with validate Regexp      0.280000   0.050000   0.330000 (  0.342968)
# with handles Array        0.550000   0.060000   0.610000 (  0.609591)
# with handles Hash         0.330000   0.050000   0.380000 (  0.396480)
# with include              0.560000   0.050000   0.610000 (  0.626158)
# with extend               0.310000   0.050000   0.360000 (  0.379358)
# ----------------------------------------------------------
