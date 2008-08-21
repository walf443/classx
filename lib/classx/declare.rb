class ClassX
  module Declare
    def classx name, &block
      klass = Class.new(ClassX)
      klass.class_eval &block
      eval "::#{name.capitalize} = klass"
    end
  end
end
