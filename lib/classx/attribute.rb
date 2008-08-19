class ClassX
  class AttributeFactory
    def self.create args
      klass = Class.new
      klass.class_eval do
        # args.each do |key, val|
        #   key = key.to_s
        #   include "ClassX::Attribute::#{key.capitalize}"
        # end
        
        # XXX: Hack for defining class method for klass
        mod = Module.new
        mod.module_eval do
          define_method :config do
            args
          end
        end
        __send__ :extend, mod

        raise ClassX::RequiredAttrShouldNotHaveDefault if args[:optional] == false && !args[:default].nil?
        raise ClassX::OptionalAttrShouldBeWritable if args[:optional] && args[:writable] == false

        define_method :initialize do |val|
          @parent = val
          @data = nil
        end

        define_method :get do
          @data ||= default
        end

        define_method :default do
          case args[:default]
          when Proc
            args[:default].call(@parent)
          else
            args[:default]
          end
        end

        define_method :lazy? do
          return args[:lazy]
        end

        define_method :optional? do
          return args[:optional]
        end

        define_method :validate? do |val|
          if args[:validate]
            case args[:validate]
            when Proc
              return args[:validate].call(val)
            when Regexp
              return args[:validate] =~ val
            else
              return args[:validate] == val
            end
          elsif klass = ( args[:isa] || args[:kind_of] )
            return val.kind_of?(klass)
          elsif args[:respond_to]
            return val.respond_to?(args[:respond_to], true)
          else
            # nothing checked.
            true
          end
        end

        define_method :set do |val|
          raise ClassX::InvalidAttrArgument unless validate? val
          @data = val
        end

        define_method :inspect do
          "<#ClassX::Attribute #{self.class.config.inspect}:#{object_id} #{ @data.nil? ? '' : '@data=' + @data.inspect } >"
        end
      end

      klass
    end
  end
end
