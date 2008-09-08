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

        it 'should define #x= private method to class' do
          @class.private_methods.map {|meth| meth.to_s }.should include("x=")
        end
    end
  end
end
