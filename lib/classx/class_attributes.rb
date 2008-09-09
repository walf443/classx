

module ClassX
  module ClassAttributes
    CLASS_ATTRIBUTE_REGEX = /\Aclass_attribute_of:(\w+)\z/

    def class_attribute_of
      unless instance_variable_defined?('@__class_attribute_of') && @__class_attribute_of
        @__class_attribute_of = {}
        private_methods.select {|meth| meth.to_s =~ CLASS_ATTRIBUTE_REGEX }.each do |meth|
          key = meth.to_s.sub(CLASS_ATTRIBUTE_REGEX) { $1 }
          @__class_attribute_of[key] = __send__("class_attribute_of:#{key}").new(self)
        end
      end

      @__class_attribute_of
    end

    private 
      def define_class_attribute name, attribute
        klass_attribute = ClassX::AttributeFactory.create(attribute)
        mod = nil
        if self.const_defined? 'ClassMethods' 
          mod = self.const_get('ClassMethods')
        else
          mod = Module.new
          const_set('ClassMethods', mod)
        end
        mod.module_eval do
          define_method "class_attribute_of:#{name}" do
            klass_attribute
          end

          private "class_attribute_of:#{name}"
        end
        self.extend(mod)
        @__class_attribute_of ||= self.class_attribute_of
        @__class_attribute_of[name] = klass_attribute.new(self)

        klass_attribute
      end

      def add_class_attribute name, attrs={}
        name = name.to_s

        attr_class = define_class_attribute(name, attrs)

        mod = nil
        if self.const_defined? 'ClassMethods' 
          mod = self.const_get('ClassMethods')
        else
          mod = Module.new
          const_set('ClassMethods', mod)
        end
        mod.module_eval do 
          # XXX: Why this can take *args?
          # =>  It's for avoid warnings when you call it without values.
          define_method name do |*vals|
            if vals == []
              @__class_attribute_data_of ||= {}
              if @__class_attribute_data_of[name]
                return @__class_attribute_data_of[name]
              else
                attr_instance = nil
                if instance_variable_defined?('@__class_attribute_of') && @__class_attribute_of
                  attr_instance = @__class_attribute_of[name] 
                else
                  @__class_attribute_of = self.class_attribute_of
                  attr_instance = @__class_attribute_of[name]
                end
                result = attr_instance.get
                raise ClassX::AttrRequiredError if result.nil? && !attr_instance.class.config[:optional]
                return @__class_attribute_data_of[name] = result
              end
            else
              raise ArgumentError if vals.size > 1
              val = vals.first
              # TODO: It's not consider whether setter method is writable.
              # I want to write following when setter method is private:
              #
              #   class SomeClass
              #       class_has :attr
              #       attr 'setting value example'
              #   end
              #
              __send__ "#{name}=", val
            end
          end

          define_method "#{name}=" do |val|
            attr_instance = nil
            if @__class_attribute_of
              attr_instance = @__class_attribute_of[name]
            else
              @__class_attribute_of = self.class_attribute_of
              attr_instance = @__class_attribute_of[name]
            end

            attr_instance.set val
            @__class_attribute_data_of ||= {}
            @__class_attribute_data_of[name] = val
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
        self.extend(mod)
      end

      alias class_has add_class_attribute
  end
end
