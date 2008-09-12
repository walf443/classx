module ClassX
  module AttributeMethods #:nodoc:
    module ClassMethods #:nodoc:
      def value_class
        config[:isa] || config[:kind_of]
      end

      # description for attribute
      def desc
        config[:desc]
      end

      # when this option specify true, not raise error in #initialize without value.
      def optional?
        return config[:optional]
      end

      # when it lazy option specified, it will not be initialized when #initialize.
      def lazy?
        return config[:lazy]
      end

      def inspect
        "ClassX::Attribute[#{self.config.inspect}]"
      end

      module CoerceWithHash #:nodoc:
        def coerce val
          result = val
          config[:coerce].each do |cond, rule|
            case cond
            when Proc
              if cond.call(val)
                result = rule.call(val)
                break
              end
            when Symbol
              if val.respond_to? cond
                result = rule.call(val)
                break
              end
            when Module
              if val.kind_of? cond
                result = rule.call(val)
                break
              end
            end
          end

          return result
        end
      end
      module CoerceWithArray #:nodoc:
        def coerce val
          result = val
          config[:coerce].each do |item|
            raise unless item.kind_of? Hash

            case item
            when Hash
              item.each do |cond, rule|
                case cond
                when Proc
                  if cond.call(val)
                    result = rule.call(val)
                    break
                  end
                end

                break if result
              end
            end

            break if result
          end

          return result
        end
      end

      module CoerceNothing #:nodoc:
        def coerce val
          val
        end
      end

      module DefaultWithProc #:nodoc:
        def default parent
          config[:default].call(parent)
        end
      end
      module DefaultWithNoProc #:nodoc:
        def default parent
          begin
            config[:default].dup
          rescue Exception
            config[:default]
          end
        end
      end

      module ValidateWithProc #:nodoc:
        def validate? val
          return config[:validate].call(val)
        end
      end

      module ValidateWithNotProc #:nodoc:
        def validate? val
          return config[:validate] === val
        end
      end

      module ValidateEach #:nodoc:
        def validate? val
          return false unless val.respond_to? :all?

          if self.value_class
            return false unless val.kind_of?(self.value_class)

            case val
            when Hash
              if config[:validate_each].arity == 2
                val.all? {|item| config[:validate_each].call(*item) }
              else
                ClassX::Validate.validate(val, &config[:validate_each])
              end
            else
              val.all? {|item| config[:validate_each].call(*item) }
            end
          else
            val.all? {|item| config[:validate_each].call(*item) }
          end
        end
      end

      module ValidateKindOf #:nodoc:
        def validate? val
          return val.kind_of?(self.value_class)
        end
      end

      module ValidateRespondTo #:nodoc:
        def validate? val
          return val.respond_to?(config[:respond_to])
        end
      end

      module ValidateNothing #:nodoc:
        def validate? val
          # nothing checked.
          true
        end
      end
    end

    module InstanceMethods #:nodoc:
      def initialize val
        @parent = val
        @data = nil
      end

      def get
        @data ||= self.class.default(@parent)
      end

      # XXX:
      #   you should not call this method except for @parent instance's setter method.
      #   It's because caching as instance_variable in @parent instance for performance.
      def set val
        val = self.class.coerce(val)
        raise ClassX::InvalidAttrArgument unless self.class.validate? val
        @data = val
      end

      def inspect
        "<#ClassX::Attribute:#{object_id} #{ @data.nil? ? '@data=nil' : '@data=' + @data.inspect } @parent=#{@parent} config=#{self.class.config.inspect}>"
      end
    end
  end

  #
  # generating anonymous class for meta attribute class.
  #
  class AttributeFactory
    def self.create args
      # TODO:  hmm, ClassX::Commandable do nothing when freezed.
      #
      # if you would like to change attribute's infomation, it's better to redefine attribute.
      # So, config should freezed.
      # args.each do |key, val|
      #   key.freeze
      #   val.freeze
      # end
      # args.freeze

      raise ClassX::RequiredAttrShouldNotHaveDefault if args[:optional] == false && !args[:default].nil?
      raise ClassX::OptionalAttrShouldBeWritable if args[:optional] && args[:writable] == false

      klass = Class.new

      klass.extend(ClassX::AttributeMethods::ClassMethods)

      # you specify type changing rule with :coerce option.
      if args[:coerce]
        case args[:coerce]
        when Hash
          klass.extend(ClassX::AttributeMethods::ClassMethods::CoerceWithHash)
        when Array
          klass.extend(ClassX::AttributeMethods::ClassMethods::CoerceWithArray)
        end
      else
        klass.extend(ClassX::AttributeMethods::ClassMethods::CoerceNothing)
      end

      # default paramater for attribute.
      # if default is Proc, run Proc every time in instanciate.
      case args[:default]
      when Proc
        klass.extend(ClassX::AttributeMethods::ClassMethods::DefaultWithProc)
      else
        klass.extend(ClassX::AttributeMethods::ClassMethods::DefaultWithNoProc)
      end

      # you can specify :validate option for checking when value is setted.
      # you can use :respond_to as shotcut for specifying { :validate => proc {|val| respond_to?(val, true) } }
      # you can use :isa or :kind_of as shotcut for specifying { :validate => proc {|val| kind_of?(val) } }
      if args[:validate]
        case args[:validate]
        when Proc
          klass.extend(ClassX::AttributeMethods::ClassMethods::ValidateWithProc)
        else
          klass.extend(ClassX::AttributeMethods::ClassMethods::ValidateWithNotProc)
        end
      elsif args[:validate_each]
        klass.extend(ClassX::AttributeMethods::ClassMethods::ValidateEach)
      elsif mod = ( args[:isa] || args[:kind_of] )
        klass.extend(ClassX::AttributeMethods::ClassMethods::ValidateKindOf)
      elsif args[:respond_to]
        klass.extend(ClassX::AttributeMethods::ClassMethods::ValidateRespondTo)
      else
        klass.extend(ClassX::AttributeMethods::ClassMethods::ValidateNothing)
      end

      # for extending attribute point.
      if args[:include]
        case args[:include]
        when Array
          args[:include].each do |mod|
            klass.__send__ :include, mod
          end
        else
          klass.__send__ :include, args[:include]
        end
      end

      if args[:extend]
        case args[:extend]
        when Array
          args[:extend].each do |mod|
            klass.__send__ :extend, mod
          end
        else
          klass.__send__ :extend, args[:extend]
        end
      end

      # XXX: Hack for defining class method for klass
      tmp_mod = Module.new
      tmp_mod.module_eval do
        define_method :config do
          args
        end
      end
      klass.extend(tmp_mod)

      klass.class_eval do
        include ClassX::AttributeMethods::InstanceMethods
      end

      klass
    end
  end
end
