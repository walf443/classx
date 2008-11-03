require File.join(File.dirname(__FILE__), 'spec_helper')
require 'classx'
require 'classx/validate'

describe ClassX::Validate, :shared => true do
  it 'should raise ArgumentError without param is not kind of Hash instance' do
    lambda { @class.new.run([]) }.should raise_error(ArgumentError)
  end

  it 'should raise ClassX::AttrRequiredError' do
    lambda { @class.new.run({}) }.should raise_error(ClassX::AttrRequiredError)
  end

  it 'should raise ClassX::InvalidArgumentError with InvalidAttrArgument' do
    lambda { @class.new.run(:x => 'hoge', :y => 'fuga') }.should raise_error(ClassX::InvalidAttrArgument)
  end

  it 'should not raise Exception' do
    lambda { @class.new.run(:x => 10, :y => 20) }.should_not raise_error(Exception)
  end

end

describe ClassX::Validate, "with cache" do
  before do
    @class = Class.new
    @class.class_eval do

      def run params
        ClassX::Validate.validate params do
          has :x
          has :y, :kind_of => Integer
        end
      end
    end
  end

  it_should_behave_like "ClassX::Validate"

  it 'should be cached auto generated class' do
    @class.new.run(:x => 10, :y => 20).class.should == @class.new.run(:x => 11, :y => 21).class
  end
end

describe ClassX::Validate, "with no cache" do
  before do
    @class = Class.new
    @class.class_eval do

      def run params
        ClassX::Validate.validate params, :cache_key => false do
          has :x
          has :y, :kind_of => Integer
        end
      end
    end
  end

  it_should_behave_like "ClassX::Validate"

  it 'should not be cached auto generated class' do
    @class.new.run(:x => 10, :y => 20).class.should_not == @class.new.run(:x => 11, :y => 21).class
  end
end
