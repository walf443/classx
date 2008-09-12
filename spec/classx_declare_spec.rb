require File.join(File.dirname(__FILE__), 'spec_helper')
require 'classx'
require 'classx/declare'

describe ClassX::Declare do
  describe 'simple define' do
    before do

      @class = Class.new
      @class.class_eval do
        extend ClassX::Declare

        classx :Class do
          has :x
        end
      end
    end

    it 'should define class into class' do
      @class.constants.map {|k| k.to_s }.should include("Class")
    end

    it 'should have attributes' do
      @class.const_get('Class').attribute_of.keys.should == ["x"]
    end
  end

  describe 'with CAttrs' do
    before do

      @class = Class.new
      @class.class_eval do
        extend ClassX::Declare

        classx :Class, [:CAttrs] do
          class_has :x
        end
      end
    end

    it 'should define class into class' do
      @class.constants.map {|k| k.to_s }.should include("Class")
    end

    it 'should have class attributes' do
      @class.const_get('Class').class_attribute_of.keys.should == ["x"]
    end
  end

  describe 'with Commandable' do
    before do

      @class = Class.new
      @class.class_eval do
        extend ClassX::Declare

        classx :Class, [:Commandable] do
        end
      end
    end

    it 'should define class into class' do
      @class.constants.map {|k| k.to_s }.should include("Class")
    end

    it 'should have :from_argv method' do
      @class.const_get('Class').respond_to?(:from_argv).should be_true
    end
  end

  describe 'with Bracketable' do
    before do

      @class = Class.new
      @class.class_eval do
        extend ClassX::Declare

        classx :Class, [:Bracketable] do
          has :x
        end
      end
    end

    it 'should define class into class' do
      @class.constants.map {|k| k.to_s }.should include("Class")
    end

    it 'should access Hash like interface' do
      obj = @class.const_get('Class').new(:x => 10)
      obj[:x].should == 10
    end
  end

  describe 'nested define' do
    before do

      @class = Class.new
      @class.class_eval do
        extend ClassX::Declare

        classx :Class do
          classx :Class do
            has :x
          end
        end
      end
    end

    it 'should define class into class' do
      @class.const_get('Class').constants.map {|k| k.to_s }.should include("Class")
    end

    it 'should have attributes' do
      @class.const_get('Class').const_get('Class').attribute_of.keys.should == ["x"]
    end
  end
end
