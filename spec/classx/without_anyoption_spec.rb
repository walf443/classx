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

        it 'should define #x= private method to class' do
          @class.private_instance_methods.map {|meth| meth.to_s }.should include("x=")
        end
    end
  end
end
