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

    describe 'with :trigger is Array' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x,
            :writable => true,
            :trigger  => [ proc {|mine,val| mine.y = val }, proc {|mine, val| mine.z = val } ]

          has :y,
            :writable => true

          has :z,
            :writable => true

        end
      end

      it 'should call each trigger when setting value' do
        obj =  @class.new(:x => 10)
        obj.x = 20
        obj.y.should == 20
        obj.z.should == 20
      end

      it 'should be able add trigger after define attribute' do
        @class.attribute_of["x"].config[:trigger].push( proc {|mine, val| raise ClassX::InvalidAttrArgument} )
        lambda {
          obj =  @class.new(:x => 10)
        }.should raise_error(ClassX::InvalidAttrArgument)
      end
    end
  end
end
