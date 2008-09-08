require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe 'Serialize' do
    before(:all) do
      klass = Class.new
      klass.class_eval do
        include ClassX
        has :x, :default => proc { [ "abc" ] }
        has :y, :default => proc { {"foo" => "bar" } }
      end

      Object.const_set(:DumpedObject, klass)
    end

    it 'should be serialized with Marshal' do
      obj = DumpedObject.new(:x => ["not abc"])
      dump = Marshal.dump(obj)
      Marshal.load(dump).should == obj
    end

    it 'should be restored instance_variables with Marshal' do
      obj = DumpedObject.new(:x => ["not abc"])
      val = "hoge"
      obj.instance_variable_set("@hoge", val)

      dump = Marshal.dump(obj)
      new_obj = Marshal.load(dump)
      new_obj.instance_variable_get("@hoge").should == val
    end

    it 'should be serialized with YAML' do
      require 'yaml'
      obj = DumpedObject.new(:x => ["not abc"])
      dump = obj.to_yaml
      YAML.load(dump).should == obj
    end

    it 'should be restored instance_variables with YAML' do
      require 'yaml'
      obj = DumpedObject.new(:x => ["not abc"])
      val = "hoge"
      obj.instance_variable_set("@hoge", val)

      dump = obj.to_yaml
      new_obj = YAML.load(dump)
      new_obj.instance_variable_get("@hoge").should == val
    end
  end
end
