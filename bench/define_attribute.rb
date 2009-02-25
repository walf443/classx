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

__END__
-
  sha1: 0.0.7
-
  sha1: 0.0.6
-
  sha1: 0.0.5
- 
  sha1: ad6a1e8be27
-
  sha1: 92ed088b
-
  sha1: dd1bb608
-
  sha1: 29a8e329
-
  sha1: 1f4c448b
