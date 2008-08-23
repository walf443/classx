require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'with handles option as Hash' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          include ClassX
          has :x, :handles => { :x_inspect => :inspect }
        end
      end

      it 'should respond_to x_inspect method' do
        obj = Object.new
        @class1.new(:x => obj).should be_respond_to(:x_inspect)
      end

      it 'should delegate method to value' do
        obj = Object.new
        @class1.new(:x => obj).x_inspect.should == obj.inspect
      end
    end

    describe 'with handles option as Array' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          include ClassX

          has :x, :handles => [ :length ]
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
    end
  end
end
