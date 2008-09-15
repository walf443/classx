require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#class_has' do
    describe 'with :trigger is Proc' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::CAttrs
          class_has :x,
            :writable => true,
            :trigger  => proc {|mine,val| mine.y = val }

          class_has :y,
            :writable => true

        end
      end

      it 'should be called when setting value' do
        @class.x = 20
        @class.y.should == 20
      end
    end
  end
end
