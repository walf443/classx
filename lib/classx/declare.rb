module ClassX
  module Declare
    def classx name, &block
      klass = Class.new
      klass.class_eval do
        include(ClassX)
      end
      klass.class_eval &block
      eval "::#{name.capitalize} = klass"
    end
  end
end
