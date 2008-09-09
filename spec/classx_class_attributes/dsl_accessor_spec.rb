require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'classx'

# This test come from dsl_accessor's test/default_test.rb

describe ClassX::ClassAttributes do
  describe 'DSLAccessor compatible' do
    describe "normal usage" do
      before :all do
        class CoolActiveRecord
          extend ClassX::ClassAttributes
          class_has :primary_key, :default  => proc { "id" }
          class_has :table_name,  :default  => proc {|klass| klass.to_s.downcase }
        end

        class Item < CoolActiveRecord
        end

        class User < CoolActiveRecord
        end

        class Folder
          extend ClassX::ClassAttributes
          class_has :array_folder, :default => []
          class_has :hash_folder,  :default => {}
        end

        class SubFolder < Folder
        end
      end

      it "should get default value when it was not setted value" do
        Item.primary_key.should == "id"
      end

      it 'should also be able to get default in subclass' do
        User.primary_key.should == "id"
      end

      it "should be able to using Proc with default value" do
        Item.table_name.should == "item"
      end

      it "should also be able to using Proc with default value in subclass" do
        User.table_name.should == "user"
      end

      it 'should be modifiable' do
        Folder.array_folder.should == []
        Folder.array_folder << 1
        Folder.array_folder.should == [1]

        Folder.hash_folder.should == {}
        Folder.hash_folder[:name] = 'walf443'
        Folder.hash_folder.should == {:name => "walf443"}
      end

      it 'should not be affect modification of parent class attribute to subclass ' do
        Folder.array_folder << 1
        SubFolder.array_folder.should == []

        Folder.hash_folder[:name] = 'walf443'
        SubFolder.hash_folder == {}
      end
    end

    describe "overwrite class accessor in subclass" do
      before :all do
       class CoolActiveRecord
         extend ClassX::ClassAttributes

         class_has :primary_key, :default=>"id"
         class_has :table_name,  :default=>proc{|klass| klass.to_s.downcase}
       end
     
       class Item < CoolActiveRecord
         primary_key :item_id
         table_name  :item_table
       end
      end

      it 'should be affect modification in subclass' do
        Item.primary_key.should == :item_id
        Item.table_name.should == :item_table
      end
    end
  end
end
