module ClassX
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
      end

      def add_attribute name, attrs={}
        name = name.to_s

        define_attribute(name, attrs)

        define_method name do
          attr_instance = __send__ "attribute_of:#{name}"
          attr_instance.get
        end

        define_method "#{name}=" do |val|
          attr_instance = __send__ "attribute_of:#{name}"
          attr_instance.set val
        end

        cached_attribute_of = attribute_of
        if cached_attribute_of[name]
          unless cached_attribute_of[name].config[:writable]
            private "#{name}="
          end

          if cached_attribute_of[name].config[:handles]
            case cached_attribute_of[name].config[:handles]
            when Hash
              cached_attribute_of[name].config[:handles].each do |before, after|
                define_method before do
                  attribute_of[name].get.__send__ after
                end
              end
            when Array
              cached_attribute_of[name].config[:handles].each do |meth|
                define_method meth do
                  attribute_of[name].get.__send__ meth
                end
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

  end
end
