require File.join(File.dirname(__FILE__), 'spec_helper')
require 'classx'

describe ClassX::Attributes do
  it 'should not raise error when you write attribute definition in module' do
    mod = Module.new
    lambda {
      mod.module_eval do
        extend ClassX::Attributes

        has :x
      end
    }.should_not raise_error(Exception)
  end

  it 'should be able to define attribute in module and use it in classX based class.' do
    mod = Module.new
    mod.module_eval do
      extend ClassX::Attributes

      has :x, :default => 10
    end

    klass = Class.new(ClassX)
    klass.class_eval do
      include mod
    end
    klass.new.x.should == 10
  end
end
