module ClassX
  module Declare
    def classx name, ctx=_guess_parent_namespace(), &block
      klass = Class.new
      klass.class_eval do
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
