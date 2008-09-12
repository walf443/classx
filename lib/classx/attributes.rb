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
      def define_attribute name, attribute
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

      def add_attribute name, attrs={}
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
              define_method before do |*args|
                __send__("#{name}").__send__ after, *args
              end
            end
          when Array
            attr_class.config[:handles].each do |meth|
              define_method meth do |*args|
                __send__("#{name}").__send__ meth, *args
              end
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
