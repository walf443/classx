require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'without accessor' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::ClassAttributes
        end
      end

      it 'should have empty attributes' do
        @class.class_attribute_of.keys.should be_empty
      end
    end
  end
end
