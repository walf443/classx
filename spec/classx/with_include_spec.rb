require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'with include' do
      before do
        @class = Class.new
        mod = Module.new
        mod.module_eval do
          define_method :test do
            :test
          end
        end
        @class.class_eval do
          include ClassX

          has :x, :include => mod
        end
      end

      it 'attrubute :x should have #test method' do
        @class.new(:x => 10).attribute_of['x'].test.should == :test
      end
    end
  end
end
