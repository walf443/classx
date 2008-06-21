require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'with multiple class' do
      before do
        @class1 = Class.new(ClassX)
        @class1.class_eval do
          has :x
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
