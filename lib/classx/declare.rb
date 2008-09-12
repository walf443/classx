module ClassX
  # you can define classx base class using DSL 
  #
  #   require 'classx'
  #   require 'classx/declare'
  #   include ClassX::Declare
  #
  #   classx :Klass do
  #     has :x
  #   end
  #
  #   Klass.new(:x => 10)
  #
  # or you can define nested.
  #
  #   classx :Klass do
  #     classx :Klass2 do
  #       has :x
  #     end
  #   end
  #
  #   #=> define Klass::Klass2
  #
  module Declare
    def classx name, options=[] , ctx=_guess_parent_namespace(), &block
      options.push(:Declare)
      klass = Class.new
      klass.class_eval do
        options.each do |mod|
          __send__ ::ClassX::MODULE_USAGE_MAP_OF[mod], ::ClassX.const_get(mod)
        end
        include(ClassX)
      end
      klass.class_eval &block
      ctx.module_eval do
        const_set(name.to_s.capitalize, klass)
      end
    end

    private
      def _guess_parent_namespace klass=self
        if self.respond_to? :module_eval
           klass
        else
           klass.class
        end
      end
  end
end
