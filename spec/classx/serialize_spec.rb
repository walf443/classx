require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

describe ClassX do
  describe 'Serialize' do
    before do
      DumpedObject = Class.new
      DumpedObject.class_eval do
        include ClassX
        has :x, :default => proc { [ "abc" ] }
        has :y, :default => proc { {"foo" => "bar" } }
      end
    end

    it 'should be serialized with Marshal' do
      obj = DumpedObject.new(:x => ["not abc"])
      dump = Marshal.dump(obj)
      Marshal.load(dump).should == obj
    end

    it 'should be serialized with YAML' do
      require 'yaml'
      obj = DumpedObject.new(:x => ["not abc"])
      dump = obj.to_yaml
      YAML.load(dump).should == obj
    end
  end
end
