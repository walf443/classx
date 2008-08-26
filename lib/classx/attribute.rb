module ClassX
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

      klass = Class.new
      klass.class_eval do
        
        # XXX: Hack for defining class method for klass
        tmp_mod = Module.new
        tmp_mod.module_eval do
          define_method :config do
            args
          end

          define_method :value_class do
            config[:isa] || config[:kind_of]
          end

          # description for attribute
          define_method :desc do
            config[:desc] 
          end

          # you specify type changing rule with :coerce option.
          if args[:coerce]
            case args[:coerce]
            when Hash
              define_method :coerce do |val|
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
            when Array
              define_method :coerce do |val|
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
          else
            define_method :coerce do |val|
              val
            end
          end

          # you can specify :validate option for checking when value is setted.
          # you can use :respond_to as shotcut for specifying { :validate => proc {|val| respond_to?(val, true) } }
          # you can use :isa or :kind_of as shotcut for specifying { :validate => proc {|val| kind_of?(val) } }
          if args[:validate]
            case args[:validate]
            when Proc
              define_method :validate? do |val|
                return config[:validate].call(val)
              end
            else
              define_method :validate? do |val|
                return config[:validate] === val
              end
            end
          elsif args[:validate_each]
            define_method :validate? do |val|
              return false unless val.respond_to? :all?

              if self.value_class
                return false unless val.kind_of?(self.value_class)

                case val
                when Hash
                  if args[:validate_each].arity == 2
                    val.all? {|item| config[:validate_each].call(*item) }
                  else
                    ClassX::Validate.validate(val, &args[:validate_each])
                  end
                else
                  val.all? {|item| config[:validate_each].call(*item) }
                end
              else
                val.all? {|item| config[:validate_each].call(*item) }
              end
            end
          elsif mod = ( args[:isa] || args[:kind_of] )
            define_method :validate? do |val|
              return val.kind_of?(self.value_class)
            end
          elsif args[:respond_to]
            define_method :validate? do |val|
              return val.respond_to?(config[:respond_to])
            end
          else
            define_method :validate? do |val|
              # nothing checked.
              true
            end
          end

          # default paramater for attribute.
          # if default is Proc, run Proc every time in instanciate.
          case args[:default]
          when Proc
            define_method :default do |parent|
              config[:default].call(parent)
            end
          else
            define_method :default do |parent|
              begin
                config[:default].dup
              rescue Exception
                config[:default]
              end
            end
          end

          # when this option specify true, not raise error in #initialize without value.
          define_method :optional? do
            return config[:optional]
          end

          # when it lazy option specified, it will not be initialized when #initialize.
          define_method :lazy? do
            return config[:lazy]
          end

          define_method :inspect do
            "ClassX::Attribute[#{self.config.inspect}]"
          end
        end
        __send__ :extend, tmp_mod

        raise ClassX::RequiredAttrShouldNotHaveDefault if args[:optional] == false && !args[:default].nil?
        raise ClassX::OptionalAttrShouldBeWritable if args[:optional] && args[:writable] == false

        define_method :initialize do |val|
          @parent = val
          @data = nil
        end

        define_method :get do
          @data ||= self.class.default(@parent)
        end

        define_method :set do |val|
          val = self.class.coerce(val)
          raise ClassX::InvalidAttrArgument unless self.class.validate? val
          @data = val
        end

        # for extending attribute point.
        if args[:include]
          case args[:include]
          when Array
            args[:include].each do |mod|
              self.__send__ :include, mod
            end
          else
            self.__send__ :include, args[:include]
          end
        end

        if args[:extend]
          case args[:extend]
          when Array
            args[:extend].each do |mod|
              self.__send__ :extend, mod
            end
          else
            self.__send__ :extend, args[:extend]
          end
        end

        define_method :inspect do
          "<#ClassX::Attribute:#{object_id} #{ @data.nil? ? '@data=nil' : '@data=' + @data.inspect } @parent=#{@parent} config=#{self.class.config.inspect}>"
        end
      end

      klass
    end
  end
end
