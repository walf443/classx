require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX::ClassAttributes do
  describe '#class_has' do
    describe 'with include' do
      describe "take a module as value" do
        before do
          @class = Class.new
          mod = Module.new
          mod.module_eval do
            define_method :test do
              :test
            end
          end
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x, :include => mod
          end
        end

        it 'attrubute :x should have #test method' do
          @class.class_eval do
            self.x = 10
          end
          @class.class_attribute_of['x'].test.should == :test
        end
      end

      describe "take multi modules as value" do
        before do
          @class = Class.new
          mod1 = Module.new
          mod1.module_eval do
            define_method :test1 do
              :test1
            end
          end

          mod2 = Module.new
          mod2.module_eval do
            define_method :test2 do
              :test2
            end
          end
          @class.class_eval do
            extend ClassX::ClassAttributes

            class_has :x, :include => [ mod1, mod2 ]
          end
        end

        it 'attrubute :x should have #test method' do
          @class.class_eval do
            self.x = 10
          end
          @class.class_attribute_of['x'].test1.should == :test1
          @class.class_attribute_of['x'].test2.should == :test2
        end
      end
    end
  end
end
