require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'without accessor' do
      before do
        @class = Class.new(ClassX)
        @class.class_eval do
        end
      end

      it 'should not raise_error' do
        lambda { @class.new }.should_not raise_error(Exception)
      end

      it 'should raise ArgumentError when recieved nil as initialize argument' do
        lambda { @class.new(nil) }.should raise_error(ArgumentError)
      end

      it 'should raise ArgumentError when recieved not kind of Hash instance as initialize argument' do
        lambda { @class.new([]) }.should raise_error(ArgumentError)
      end

      it 'should have empty attributes' do
        @class.attribute_of.keys.should be_empty
      end
    end
  end
end
