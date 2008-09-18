require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'with coece' do
      describe 'when Array is value' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x, :isa => Integer, :coerce => [
              { proc {|val| val.respond_to? :to_i } => proc {|val| val.to_i } },
              { proc {|val| val.respond_to? :to_s } => proc {|val| val.to_s } },
            ]
          end
        end

        it 'attrubute :x should convert Str to Integer' do
          lambda {
            @class.class_eval do
              self.x = "10"
            end
          }.should_not raise_error(Exception)
        end

        it 'attrubute :x should not convert  Object to Integer' do
          lambda {
            @class.class_eval do
              self.x = Object.new
            end
          }.should raise_error(ClassX::InvalidAttrArgument)
        end
      end

      describe 'when Proc is value' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x, :isa => Integer, :coerce => proc {|val| ( val.respond_to?(:to_i) && val.to_i > 0 ) ? val.to_i : val }
          end
        end

        it 'attrubute :x should convert Str to Integer' do
          lambda {
            @class.class_eval do
              self.x = 10
            end
          }.should_not raise_error(Exception)
          @class.x.should == 10
        end

        it 'attrubute :x should not convert  Object to Integer' do
          lambda {
            @class.class_eval do
              self.x = Object.new
            end
          }.should raise_error(ClassX::InvalidAttrArgument)
        end
      end
      describe 'when Proc is key' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x, :isa => Integer, :coerce => { proc {|val| val.respond_to? :to_i } => proc {|val| val.to_i } }
          end
        end

        it 'attrubute :x should convert Str to Integer' do
          lambda {
            @class.class_eval do
              self.x = "10"
            end
          }.should_not raise_error(Exception)
        end

        it 'attrubute :x should not convert  Object to Integer' do
          lambda {
            @class.class_eval do
              self.x = Object.new
            end
          }.should raise_error(ClassX::InvalidAttrArgument)
        end
      end

      describe 'when Symbol is key' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x, :isa => Integer, :coerce => { :to_i => proc {|val| val.to_i } }
          end
        end

        it 'attrubute :x should convert Str to Integer' do
          lambda {
            @class.class_eval do
              self.x = 10
            end
          }.should_not raise_error(Exception)
        end

        it 'attrubute :x should not convert  Object to Integer' do
          lambda {
            @class.class_eval do
              self.x = Object.new
            end
          }.should raise_error(ClassX::InvalidAttrArgument)
        end
      end

      describe 'when Module or Class is key' do
        before do
          @class = Class.new
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x, :isa => Integer, :coerce => { String => proc {|val| val.to_i } }
          end
        end

        it 'attrubute :x should convert Str to Integer' do
          lambda {
            @class.class_eval do
              self.x = 10
            end
          }.should_not raise_error(Exception)
        end

        it 'attrubute :x should not convert  Object to Integer' do
          lambda {
            @class.class_eval do
              self.x = Object.new
            end
          }.should raise_error(ClassX::InvalidAttrArgument)
        end
      end
    end
  end
end
