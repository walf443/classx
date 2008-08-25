require 'benchmark'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'classx'

COUNT = 1000
Benchmark.bm do |x|
  x.report "simple define" do
    class SimpleDefine
      include ClassX

      att_name = 'a'
      COUNT.times {
        has att_name
        att_name = att_name.succ
      }
    end
  end
end
