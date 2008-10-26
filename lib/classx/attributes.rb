module ClassX
  #
  # added attribute feature to module.
  #
  #   require 'classx'
  #   module YourApp::Role::SomeModule
  #     extend Attributes
  #
  #     has :some_attr
  #
  #   end
  #
  #   class YourApp
  #     included ClassX
  #     included YourApp::Role::SomeModule
  #
  #   end
  #
  #   YourApp.new(:some_attr => 10)
  #
  module Attributes
    ATTRIBUTE_REGEX = /\Aattribute_of:(\w+)\z/

    # return Hash of attribute's name as a key and attribute's meta class as a value.
    # for example, 
    #
    #   class YourClass
    #      include ClassX
    #      has :x
    #   end
    #
    #   YourClass.attribute_of  #=> { "x" => <ClassX::Attribute: ... > }
    #
    def attribute_of
      unless instance_variable_defined?('@__attribute_of') && @__attribute_of
        @__attribute_of = {}
        private_instance_methods.select {|meth| meth.to_s =~ ATTRIBUTE_REGEX }.each do |meth|
          key = meth.to_s.sub(ATTRIBUTE_REGEX) { $1 }
          @__attribute_of[key] = __send__ "attribute_of:#{key}"
        end
      end

      @__attribute_of
    end

    private 
      # generating attribute's meta class and bind to this class.
      #
      def define_attribute name, attribute #:doc:
        klass_attribute = ClassX::AttributeFactory.create(attribute)
        mod = nil
        if self.const_defined? 'ClassMethods' 
          mod = self.const_get('ClassMethods')
        else
          mod = Module.new
          const_set('ClassMethods', mod)
        end
        mod.module_eval do
          define_method "attribute_of:#{name}" do
            klass_attribute
          end

          private "attribute_of:#{name}"
        end
        self.extend(mod)
        @__attribute_of ||= self.attribute_of
        @__attribute_of[name] = klass_attribute

        define_method "attribute_of:#{name}" do
          @__attribute_of ||= {}
          @__attribute_of[name] ||= klass_attribute.new(self)
        end

        private "attribute_of:#{name}"

        klass_attribute
      end

      # adding new attribute to class, and define accessor methods related to this attribute.
      # You can also use +has+ more declaretivly.
      #
      #   class YourClass
      #     include ClassX
      #     add_attribute :x,
      #       :writable => true,  # defining accessor scope.
      #       :optional => ture,  # defining attribute is required in initialize.
      #       :validate => proc {|val| val.respond_to? :to_s }  # this attribute's value should adopted to this rule.
      #       :default  => proc {|mine| mine.class.to_s.split(/::/).last.downcase } # default value for this attribute.
      #
      #   end
      #
      def add_attribute name, attrs={} #:doc:
        name = name.to_s

        attr_class = define_attribute(name, attrs)

        # XXX: Why this can take *args?
        # =>  It's for avoid warnings when you call it without values.
        define_method name do |*vals|
          if vals == []
            @__attribute_data_of ||= {}
            if @__attribute_data_of[name]
              return @__attribute_data_of[name]
            else
              attr_instance = __send__ "attribute_of:#{name}"
              return @__attribute_data_of[name] = attr_instance.get
            end
          else
            raise ArgumentError if vals.size > 1
            val = vals.first
            if respond_to? "#{name}="
              __send__ "#{name}=", val
            else
              raise RuntimeError, ":#{name} is not writable"
            end
          end
        end

        define_method "#{name}=" do |val|
          attr_instance = __send__ "attribute_of:#{name}"
          attr_instance.set val
          @__attribute_data_of ||= {}
          @__attribute_data_of[name] = val
        end

        unless attr_class.config[:writable]
          private "#{name}="
        end

        if attr_class.config[:handles]
          case attr_class.config[:handles]
          when Hash
            attr_class.config[:handles].each do |before, after|
              class_eval <<-CLASS_EVAL
                def #{before} *args, &block
                  __send__("#{name}").__send__ "#{after}", *args, &block
                end
              CLASS_EVAL
            end
          when Array
            attr_class.config[:handles].each do |meth|
              class_eval <<-CLASS_EVAL
                def #{meth} *args, &block
                  __send__("#{name}").__send__ "#{meth}", *args, &block
                end
              CLASS_EVAL
            end
          end
        end
      end

      alias has add_attribute

      # hook for module to ClassX base class.
      def included klass
        klass.extend(self.const_get('ClassMethods'))
      end

      # alias for lazy people
      Attrs = Attributes
  end
end
