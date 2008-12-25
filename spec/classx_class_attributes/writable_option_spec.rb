require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'with :writable option' do
      describe 'when you specify false for attribute' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes
            class_has :x, :writable => false
          end
        end

        it 'should define class.x public method to class' do
          @class.methods.map {|meth| meth.to_s }.should include('x')
        end

        it 'should define class.x= private method to class' do
          @class.private_methods.map {|meth| meth.to_s }.should include("x=")
        end

        it 'should have attributes [:x]' do
          @class.class_attribute_of.keys.should == ['x']
        end

        it 'should raise NoMethodError using attr_name = val' do
          lambda { @class.x = 20 }.should raise_error(NoMethodError)
        end

        # NOTE: why don't it unify Exception Class between above and this?
        # => This exception was caused by mistake of program. So, in general I think, you should not
        # rascue this error.
        it 'should raise RuntimeError using attr_name(val)' do
          pending do
            lambda { @class.x(20) }.should raise_error(RuntimeError)
          end
        end
      end

      describe 'when you specify true for attribute' do 
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes
            class_has :x, :writable => true
          end
        end

        it 'should define class.x public method to class' do
          @class.methods.map {|meth| meth.to_s }.should include('x')
        end

        it 'should define class.x= public method to class' do
          @class.public_methods.map {|meth| meth.to_s }.should include("x=")
        end

        it 'should have attributes [:x]' do
          @class.class_attribute_of.keys.should == ['x']
        end

        it 'should update value using attr_name = val' do
          @class.x = 20
          @class.x.should == 20
        end

        it 'should update value using attr_name(val)' do
          @class.x(20)
          @class.x.should == 20
        end
      end

    end

    describe 'with :writable is false' do
      it 'should raise ClassX::OptionalAttrShouldBeWritable' do
        lambda {
          klass = Class.new
          klass.class_eval do 
            extend ClassX::ClassAttributes
            class_has :x, :optional => true, :writable => false
          end
        }.should raise_error(ClassX::OptionalAttrShouldBeWritable)
      end
    end

    describe 'with :writable is true' do
      it 'should not raise ClassX::OptionalAttrShouldBeWritable' do
        lambda {
          klass = Class.new
          klass.class_eval do 
            extend ClassX::ClassAttributes
            class_has :x, :optional => true, :writable => true
          end
        }.should_not raise_error(ClassX::OptionalAttrShouldBeWritable)
      end
    end
  end
end
