require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'without any option' do
        before do
          @class = Class.new
          @class.class_eval do
            include ClassX

            has :x
          end
        end

        it 'should required :x on initialize' do
          lambda { @class.new }.should raise_error(ClassX::AttrRequiredError)
        end

        it 'should be able to rewrite :x attribute' do
          instance =@class.new(:x => 10)
          instance.x = 20
          instance.x.should == 20
        end
    end
  end
end
