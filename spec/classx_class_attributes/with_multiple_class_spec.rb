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

  end
end
