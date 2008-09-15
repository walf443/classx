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

    describe 'with :trigger is Array' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::CAttrs
          class_has :x,
            :writable => true,
            :trigger  => [ proc {|mine,val| mine.y = val }, proc {|mine, val| mine.z = val } ]

          class_has :y,
            :writable => true

          class_has :z,
            :writable => true

        end
      end

      it 'should call each trrigger when setting value' do
        @class.x = 20
        @class.y.should == 20
        @class.z.should == 20
      end

      it 'should be able add trigger after define attribute' do
        @class.class_attribute_of["x"].class.config[:trigger].push( proc {|mine, val| raise ClassX::InvalidAttrArgument} )
        lambda {
          @class.x = 10
        }.should raise_error(ClassX::InvalidAttrArgument)
      end
    end
  end
end
