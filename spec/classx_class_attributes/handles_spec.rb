require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'with handles option as Hash' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          extend ClassX::ClassAttributes
          class_has :x, :handles => { 
            :x_inspect => :inspect,
            :x_slice => :slice
          }
        end
      end

      it 'should respond_to x_inspect method' do
        obj = []
        @class1.respond_to?(:x_inspect).should be_true
      end

      it 'should delegate method to value' do
        obj = []
        @class1.class_eval do
          self.x = obj
        end
        @class1.x_inspect.should == obj.inspect
      end

      it 'should delegate method with args to value' do
        obj = []
        obj.push 1
        @class1.class_eval do
          self.x = obj
        end
        @class1.x_slice(0).should == obj.slice(0)
      end
    end

    describe 'with handles option as Array' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          extend ClassX::ClassAttributes

          class_has :x, :handles => [ :length, :slice ]
        end
      end

      it 'should respond_to item name method' do
        obj = [1, 2, 3]
        @class1.class_eval do
          self.x = obj
        end
        @class1.respond_to?(:length).should be_true
      end

      it 'should delegate method to the same item name' do
        obj = [1, 2, 3]
        @class1.class_eval do
          self.x = obj
        end
        @class1.length.should == obj.length
      end

      it 'should delegate method with args to value' do
        obj = [1, 2, 3]
        obj.push 1
        @class1.class_eval do
          self.x = obj
        end
        @class1.slice(0).should == obj.slice(0)
      end
    end
  end
end
