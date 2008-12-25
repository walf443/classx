require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'without any option' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x
          end
        end

        it 'should be able to rewrite :x attribute' do
          @class.x = 10
          @class.x.should == 10
        end
    end
  end
end
