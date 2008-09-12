require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe '#has' do
    describe 'with :validate option' do
      describe 'when value is Proc' do
        before do
          @class = Class.new
          @class.class_eval do
            include ClassX
            has :x, 
              :writable => true,
              :validate => proc {|val| val.kind_of? Fixnum }
          end
        end

        it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
          lambda { @class.new(:x => "str") }.should raise_error(ClassX::InvalidAttrArgument) 
        end

        it 'should not raise error when it take valid args on instanciate' do
          lambda { @class.new(:x => 10) }.should_not raise_error(Exception) 
        end

        it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
          instance = @class.new(:x => 10)
          lambda { instance.x = "str" }.should raise_error(ClassX::InvalidAttrArgument) 
        end

        it 'should not raise error when it take valid args on update value' do
          instance = @class.new(:x => 10)
          lambda { instance.x = 20 }.should_not raise_error(Exception) 
        end
      end

      describe "when value is Regexp" do
        before do
          @class = Class.new
          @class.class_eval do
            include ClassX
            has :x, 
              :writable => true,
              :validate => /^test_/

          end
        end

        it 'should raise ClassX::InvalidAttrArgument when it take invalid args on instanciate' do
          lambda { @class.new(:x => "hoge") }.should raise_error(ClassX::InvalidAttrArgument)
        end

        it 'should raise ClassX::InvalidAttrArgument when it take none String argument on instanciate' do
          lambda { @class.new(:x => :hoge ) }.should raise_error(ClassX::InvalidAttrArgument)
        end

        it 'should not raise error when it take valid args on instanciate' do
          lambda { @class.new(:x => "test_hoge") }.should_not raise_error(Exception)
        end

        it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
          instance = @class.new(:x => 'test_hoge')
          lambda { instance.x = "hoge" }.should raise_error(ClassX::InvalidAttrArgument)
        end

        it 'should raise ClassX::InvalidAttrArgument when it take none String argument on update value' do
          instance = @class.new(:x => 'test_hoge')
          lambda { instance.x = :fuga }.should raise_error(ClassX::InvalidAttrArgument)
        end

        it 'should not raise error when it take valid args on update value' do
          instance = @class.new(:x => 'test_hoge')
          lambda { instance.x = "test_fuga" }.should_not raise_error(Exception)
        end
      end

      describe 'when value is not Regexp or Proc' do
        before do
          @class = Class.new
          @class.class_eval do
            include ClassX
            has :x, 
              :writable => true,
              :validate => "validate_value"

          end
        end

        it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
          lambda { @class.new(:x => "hoge") }.should raise_error(ClassX::InvalidAttrArgument) 
        end

        it 'should not raise error when it take valid args on instanciate' do
          lambda { @class.new(:x => "validate_value") }.should_not raise_error(Exception) 
        end

        it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
          instance = @class.new(:x => "validate_value")
          lambda { instance.x = "hoge" }.should raise_error(ClassX::InvalidAttrArgument) 
        end

        it 'should not raise error when it take valid args on update value' do
          instance = @class.new(:x => "validate_value")
          lambda { instance.x = "validate_value" }.should_not raise_error(Exception) 
        end
      end
    end

    describe 'with :kind_of option' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :kind_of => Fixnum
        end
      end

      it 'should define value_class' do
        @class.attribute_of['x'].value_class.should == Fixnum
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => "str") }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => 10) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => 10)
        lambda { instance.x = "str" }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => 10)
        lambda { instance.x = 20 }.should_not raise_error(Exception) 
      end
    end

    describe 'with :isa option' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :isa => Fixnum
        end
      end

      it 'should define value_class' do
        @class.attribute_of['x'].value_class.should == Fixnum
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => "str") }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => 10) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => 10)
        lambda { instance.x = "str" }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => 10)
        lambda { instance.x = 20 }.should_not raise_error(Exception) 
      end
    end

    describe 'with :respond_to option' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :respond_to => :to_int
        end
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => "str") }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => 10) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => 10)
        lambda { instance.x = "str" }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => 10)
        lambda { instance.x = 20 }.should_not raise_error(Exception) 
      end
    end

    describe 'with :validate_each option and take Array' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :validate_each => proc {|item| item.kind_of? String }
        end
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => [ "str", 10 ]) }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => ['abc', 'def'] ) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => ['abc', 'def' ])
        lambda { instance.x = ["str", 10] }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => ['abc', 'def'])
        lambda { instance.x = ['ghi', 'jkl'] }.should_not raise_error(Exception) 
      end
    end

    describe 'with :validate_each option and take Array' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :kind_of  => Array,
            :validate_each => proc {|item| item.kind_of? String }
        end
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => [ "str", 10 ]) }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => ['abc', 'def'] ) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => ['abc', 'def' ])
        lambda { instance.x = ["str", 10] }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => ['abc', 'def'])
        lambda { instance.x = ['ghi', 'jkl'] }.should_not raise_error(Exception) 
      end
    end

    describe 'with :validate_each option and take Hash' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :validate_each => proc {|key,val| val.kind_of? String }
        end
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => { 'abc' => 10 }) }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => { 'abc' => 'str' } ) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => {'abc' => 'str' })
        lambda { instance.x = {'abc' => 10 } }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => {'abc' => 'str' })
        lambda { instance.x = { 'ghi' => 'jkl' } }.should_not raise_error(Exception) 
      end
    end

    describe 'with :validate_each option with arity two and :kind_of and take Hash' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :kind_of  => Hash,
            :validate_each => proc {|key,val| val.kind_of? String }
        end
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => { 'abc' => 10 }) }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => { 'abc' => 'str' } ) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => {'abc' => 'str' })
        lambda { instance.x = {'abc' => 10 } }.should raise_error(ClassX::InvalidAttrArgument) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => {'abc' => 'str' })
        lambda { instance.x = { 'ghi' => 'jkl' } }.should_not raise_error(Exception) 
      end
    end

    describe 'with :validate_each option with arity two and :kind_of and take Hash' do
      before do
        @class = Class.new
        @class.class_eval do
          include ClassX
          has :x, 
            :writable => true,
            :kind_of  => Hash,
            :validate_each => proc {|mod|
              has :foo
              has :bar
            }
        end
      end

      it 'should raise ClassX::InstanceException when it take invalid args on instanciate' do
        lambda { @class.new(:x => { 'abc' => 10 }) }.should raise_error(ClassX::AttrRequiredError) 
      end

      it 'should not raise error when it take valid args on instanciate' do
        lambda { @class.new(:x => { 'foo' => :foo, "bar" => :bar } ) }.should_not raise_error(Exception) 
      end

      it 'should raise ClassX::InvalidAttrArgument when it take invalid args on update value' do
        instance = @class.new(:x => {'foo' => :foo, "bar" => :bar })
        lambda { instance.x = {'abc' => 10 } }.should raise_error(ClassX::AttrRequiredError) 
      end

      it 'should not raise error when it take valid args on update value' do
        instance = @class.new(:x => {'foo' => :foo, "bar" => :bar })
        lambda { instance.x = {'foo' => :foo, "bar" => :bar, "baz" => :baz } }.should_not raise_error(Exception) 
      end
    end
  end
end
