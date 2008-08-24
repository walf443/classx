require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'with handles option as Hash' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          include ClassX
          has :x, :handles => { 
            :x_inspect => :inspect,
            :x_slice => :slice
          }
        end
      end

      it 'should respond_to x_inspect method' do
        obj = []
        @class1.new(:x => obj).should be_respond_to(:x_inspect)
      end

      it 'should delegate method to value' do
        obj = []
        @class1.new(:x => obj).x_inspect.should == obj.inspect
      end

      it 'should delegate method with args to value' do
        obj = []
        obj.push 1
        @class1.new(:x => obj).x_slice(0).should == obj.slice(0)
      end
    end

    describe 'with handles option as Array' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          include ClassX

          has :x, :handles => [ :length, :slice ]
        end
      end

      it 'should respond_to item name method' do
        obj = [1, 2, 3]
        @class1.new(:x => obj).should be_respond_to(:length)
      end

      it 'should delegate method to the same item name' do
        obj = [1, 2, 3]
        @class1.new(:x => obj).length.should == obj.length
      end

      it 'should delegate method with args to value' do
        obj = [1, 2, 3]
        obj.push 1
        @class1.new(:x => obj).slice(0).should == obj.slice(0)
      end
    end
  end
end
