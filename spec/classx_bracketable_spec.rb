require File.join(File.dirname(__FILE__), 'spec_helper')
require 'classx'
require 'classx/bracketable'

describe ClassX::Bracketable do
  describe 'for attribute' do
    describe 'with writable attribute' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          include ClassX::Bracketable

          has :x, :writable => true
        end

        @obj = @class.new(:x => 10)
      end

      it 'should be able to access Hash like interface' do
        @obj[:x].should == 10
      end

      it 'should return nil when you access non-attribute class' do
        @obj[:y].should be_nil
      end

      it 'should be able to set value' do
        @obj[:x] = 20
        @obj[:x].should == 20
      end
    end

    describe 'with non-writable attribute' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          include ClassX::Bracketable

          has :x, :writable => false
        end

        @obj = @class.new(:x => 10)
      end

      it 'should be able to access Hash like interface' do
        @obj[:x].should == 10
      end

      it 'should return nil when you access non-attribute class' do
        @obj[:y].should be_nil
      end

      it 'should be raise NoMethodError in setting value to non writable attribute' do
        lambda { @obj[:x] = 20 }.should raise_error(NoMethodError)
      end
    end

    describe 'with non-attribute method' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          include ClassX::Bracketable

          has :x

          attr_accessor :y
        end

        @obj = @class.new(:x => 10)
        @obj.y = 10
      end

      it 'should be able to access attrubte as Hash like interface' do
        @obj[:x].should == 10
      end

      it 'should return nil when you access non-attribute class' do
        @obj[:y].should be_nil
      end
    end
  end

  describe 'for class attribute' do
    describe 'with writable class attribute' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::CAttrs
          extend ClassX::Bracketable

          class_has :x, :writable => true

          self.x = 10
        end
      end

      it 'should be able to access class attribute as Hash like interface' do
        @class[:x].should == 10
      end

      it 'should return nil when you access non-class-attribute class' do
        @class[:y].should be_nil
      end

      it 'should be able to set value' do
        @class[:x] = 20
        @class[:x].should == 20
      end
    end

    describe 'with non-writable class attribute' do
      before do
        @class = Class.new
        @class.class_eval do
          extend ClassX::CAttrs
          extend ClassX::Bracketable

          class_has :x, :writable => false

          self.x = 10
        end
      end

      it 'should be able to access class attribute as Hash like interface' do
        @class[:x].should == 10
      end

      it 'should return nil when you access non-class-attribute class' do
        @class[:y].should be_nil
      end

      it 'should be raise NoMethodError in setting value to non writable class attribute' do
        lambda { @class[:x] = 20 }.should raise_error(NoMethodError)
      end
    end
  end

  describe 'for non-ClassX class' do
    before do
      @class = Class.new
      @class.class_eval do
        include ClassX::Bracketable
      end

      @obj = @class.new
    end

    it 'should return nil' do
      @obj[:x].should be_nil
    end

    it 'should return nil' do
      @obj[:x] = 20
      @obj[:x].should be_nil
    end
  end
end
