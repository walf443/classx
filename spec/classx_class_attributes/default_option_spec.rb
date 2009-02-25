require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'
require 'classx/class_attributes'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'with :default option' do
      describe 'when value is Proc' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes
            class_has :x, :default => proc { Object.new }
          end
        end

        it 'should have any value accessing accessor' do
          @class.x.should_not be_nil
        end

        it "can use self as Proc's argument" do
          @class.class_eval do
            class_has :y, :default => proc {|mine| mine.x }, :lazy => true
            class_has :z, :default => proc {|mine| mine.y }, :lazy => true
          end

          @class.y.should equal(@class.x)
          @class.z.should equal(@class.y)
        end
      end

      describe 'when value is not Proc' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes
            class_has :x, :default => []
          end
        end

        it 'should have any value when instanciate' do
          @class.x.should == []
        end
      end
    end

    describe 'with :optional is false' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::ClassAttributes
          class_has :x, :optional => false
        end
      end

      it "should raise AttrRequiredError without value" do
        lambda { @class.x }.should raise_error(ClassX::AttrRequiredError)
      end

      it "should not raise AttrRequiredError with value" do
        lambda { @class.x = Object.new; @class.x }.should_not raise_error(ClassX::AttrRequiredError)
      end
    end

    describe ':optional is false and with :default option' do
      it 'should raise ClassX::RequiredAttrShouldNotHaveDefault' do
        lambda {
          klass = Class.new
          klass.class_eval do
            extend ClassX::ClassAttributes
            class_has :x, :optional => false, :default => 1
          end
        }.should raise_error(ClassX::RequiredAttrShouldNotHaveDefault)
      end
    end

    describe 'declare attribute without :optional and :default option' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::ClassAttributes
          class_has :x, :kind_of => Integer
        end
      end

      it 'should be required attribute' do
        lambda { @class.x }.should raise_error(ClassX::AttrRequiredError)
      end
    end

    describe ':optional is true and without :default option' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::ClassAttributes
          class_has :x, :optional => true, :kind_of => Integer
        end
      end

      it 'should not be required attribute' do
        lambda { @class.x }.should_not raise_error(ClassX::AttrRequiredError)
      end
    end

    describe 'with :optional is true' do
      describe 'without :writable option' do
        before do
          @class = Class.new
          @class.class_eval do 
            extend ClassX::ClassAttributes
            class_has :x, :optional => true
          end
        end
        it 'should not raise AttrRequiredError' do
          lambda { @class.x }.should_not raise_error(ClassX::AttrRequiredError)
        end
      end
    end
  end
end
