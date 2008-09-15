require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'with :trigger is Proc' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x,
            :writable => true,
            :trigger  => proc {|mine,val| mine.y = val }

          has :y,
            :writable => true

        end
      end

      it 'should be called when setting value' do
        obj =  @class.new(:x => 10)
        obj.x = 20
        obj.y.should == 20
      end
    end
  end
end
