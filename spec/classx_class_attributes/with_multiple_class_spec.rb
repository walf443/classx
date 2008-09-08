require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'with multiple class' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          extend ClassX::ClassAttributes
          class_has :x
        end
        @class2 = Class.new
        @class2.class_eval do
          extend ClassX::ClassAttributes
        end
      end

      it 'should not raise AttrRequiredError when initialized anothor class' do
        lambda { @class2.class_attribute_of }.should_not raise_error(ClassX::AttrRequiredError)
      end
    end

    describe 'inherit class accessor' do
      before do
        @class1 = Class.new
        @class1.class_eval do
          extend ClassX::ClassAttributes
          class_has :x, :default => :default
        end
        @class2 = Class.new(@class1)
      end

      it 'should inherit class attribute' do
        @class2.class_attribute_of.keys.should == ['x']
      end

      it "should not be same class attribute's instance" do
        @class1.class_attribute_of.each do |k1, v1|
          @class2.class_attribute_of.each do |k2, v2|
            if k1 == k2
              v1.should_not == v2
            end
          end
        end
      end

      it "should not affect subclass changing class attribute value" do
        @class1.class_eval do
          self.x = "hoge"
        end
        @class2.x.should_not == "hoge"
      end

      it 'should be able to inherit default value' do
        @class2.x.should == :default
      end
    end
  end
end
