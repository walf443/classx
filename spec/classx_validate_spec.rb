require File.join(File.dirname(__FILE__), 'spec_helper')
require 'classx'
require 'classx/validate'

describe ClassX::Validate do
  include ClassX::Validate
  before do
    @class = Class.new
    @class.class_eval do
      include ClassX::Validate

      def run params
        validate params do
          has :x, :required => true
          has :y, :required => true, :kind_of => Integer
        end
      end
    end
  end

  it 'should raise ArgumentError without param is not kind of Hash instance' do
    lambda { @class.new.run([]) }.should raise_error(ArgumentError)
  end

  it 'should raise ClassX::AttrRequiredError' do
    lambda { @class.new.run({}) }.should raise_error(ClassX::AttrRequiredError)
  end

  it 'should raise ClassX::InvalidArgumentError with InvalidArgument' do
    lambda { @class.new.run(:x => 'hoge', :y => 'fuga') }.should raise_error(ClassX::InvalidSetterArgument)
  end

  it 'should not raise Exception' do
    lambda { @class.new.run(:x => 10, :y => 20) }.should_not raise_error(Exception)
  end
end
