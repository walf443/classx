require File.join(File.dirname(__FILE__), 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'without accessor' do
      before do
        @class = Class.new(ClassX)
        @class.class_eval do
        end
      end

      it 'should not raise_error' do
        lambda { @class.new }.should_not raise_error(Exception)
      end

      it 'should raise ArgumentError when recieved nil as initialize argument' do
        lambda { @class.new(nil) }.should raise_error(ArgumentError)
      end

      it 'should raise ArgumentError when recieved not kind of Hash instance as initialize argument' do
        lambda { @class.new([]) }.should raise_error(ArgumentError)
      end

      it 'should have empty attributes' do
        @class.attributes.should be_empty
      end
    end

    describe 'with :is option' do
      describe 'when you specify :ro for attribute' do
        before do
          @class = Class.new(ClassX)
          @class.class_eval do
            has :x, :is => :ro
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

      describe 'when you specify :rw for attribute' do 
        before do
          @class = Class.new(ClassX)
          @class.class_eval do
            has :x, :is => :rw
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

    describe 'with :default option' do
      describe 'when value is Proc' do
        before do
          @class = Class.new(ClassX)
          @class.class_eval do
            has :x, :default => proc { Object.new }
          end
        end

        it 'shouold have any value when instanciate' do
          @class.new.x.should_not be_nil
        end

        it 'should have difference of object_id between some instance' do
          @class.new.x.should_not equal(@class.new.x)
        end

        # TODO: with lazy option
        # it "can use self as Proc's argument" do
        #   @class.class_eval do
        #     has :y, :default => proc {|mine| mine.x }
        #   end

        #   @class.new.y.should equal(@class.new.x)
        # end
      end

      describe 'when value is not Proc' do
        before do
          @class = Class.new(ClassX)
          @class.class_eval do
            has :x, :default => []
          end
        end

        it 'should have any value when instanciate' do
          @class.new.x.should == []
        end

        it 'should have the same object_id between some instance' do
          @class.new.x.should equal(@class.new.x)
        end
      end
    end

    describe 'with :required option' do
      before do
        @class = Class.new(ClassX)
        @class.class_eval do
          has :x, :required => true
        end
      end

      it "should raise AttrRequiredError without value" do
        lambda { @class.new }.should raise_error(ClassX::AttrRequiredError)
      end

      it "should not raise AttrRequiredError with value" do
        lambda { @class.new(:x => Object.new) }.should_not raise_error(ClassX::AttrRequiredError)
      end

      it 'should not raise AttrRequiredError with key as String' do
        lambda { @class.new('x' => Object.new) }.should_not raise_error(ClassX::AttrRequiredError)
      end
    end

    describe 'with :required and :default option' do
      it 'should raise ClassX::RequiredAttrShouldNotHaveDefault' do
        lambda {
          klass = Class.new(ClassX)
          klass.class_eval do
            has :x, :required => true, :default => 1
          end
        }.should raise_error(ClassX::RequiredAttrShouldNotHaveDefault)
      end
    end

    describe 'with multiple class' do
      before do
        @class1 = Class.new(ClassX)
        @class1.class_eval do
          has :x, :required => true
        end
        @class2 = Class.new(ClassX)
        @class2.class_eval do
        end
      end

      it 'should not raise AttrRequiredError when initialized anothor class' do
        lambda { @class2.new }.should_not raise_error(ClassX::AttrRequiredError)
      end
    end
  end
end
