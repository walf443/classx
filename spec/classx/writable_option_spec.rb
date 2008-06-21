require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'with :writable option' do
      describe 'when you specify false for attribute' do
        before do
          @class = Class.new(ClassX)
          @class.class_eval do
            has :x, :writable => false
          end
        end

        it 'should define #x public method to class' do
          @class.instance_methods.map {|meth| meth.to_s }.should be_include('x')
        end

        it 'should define #x= private method to class' do
          @class.private_instance_methods.map {|meth| meth.to_s }.should be_include("x=")
        end

        it 'should have attributes [:x]' do
          @class.attributes.should == ['x']
        end
      end

      describe 'when you specify true for attribute' do 
        before do
          @class = Class.new(ClassX)
          @class.class_eval do
            has :x, :writable => true
          end
        end

        it 'should define #x public method to class' do
          @class.instance_methods.map {|meth| meth.to_s }.should be_include('x')
        end

        it 'should define #x= public method to class' do
          @class.public_instance_methods.map {|meth| meth.to_s }.should be_include("x=")
        end

        it 'should have attributes [:x]' do
          @class.attributes.should == ['x']
        end
      end

    end

    describe 'with :writable is false' do
      it 'should raise ClassX::OptionalAttrShouldBeWritable' do
        lambda {
          klass = Class.new(ClassX)
          klass.class_eval do 
            has :x, :optional => true, :writable => false
          end
        }.should raise_error(ClassX::OptionalAttrShouldBeWritable)
      end
    end

    describe 'with :writable is true' do
      it 'should raise ClassX::OptionalAttrShouldBeWritable' do
        lambda {
          klass = Class.new(ClassX)
          klass.class_eval do 
            has :x, :optional => true, :writable => true
          end
        }.should_not raise_error(ClassX::OptionalAttrShouldBeWritable)
      end
    end
  end
end
