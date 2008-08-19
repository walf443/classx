class ClassX
  module Attributes
    def define_attribute name, attribute
      @__attribute_param_of ||= {}
      @__attribute_param_of[name] = klass_attribute = ClassX::AttributeFactory.create(attribute)
      define_method "attribute_of:#{name}" do
        @__attribute_of ||= {}
        @__attribute_of[name] ||= klass_attribute.new(self)
      end

      private "attribute_of:#{name}"
    end

    ATTRIBUTE_REGEX = /\Aattribute_of:(\w+)\z/

    def attribute_of
      hash = {}
      @__attribute_param_of ||= {}
      private_instance_methods.map {|meth| meth.to_s }.each do |meth|
        next unless meth =~ ATTRIBUTE_REGEX
        hash[$1] = @__attribute_param_of[$1]
      end

      hash
    end

    def add_attribute name, attrs={}
      name = name.to_s

      unless private_instance_methods.map {|meth| meth.to_s }.include?('attribute_of')
        define_method :attribute_of do
          hash = {}
          private_methods.map {|meth| meth.to_s }.each do |meth|
            next unless meth =~ ATTRIBUTE_REGEX
            hash[$1] = __send__ "attribute_of:#$1"
          end

          hash
        end
      end

      define_attribute(name, attrs)

      define_method name do
        attribute_of[name].get
      end

      define_method "#{name}=" do |val|
        attribute_of[name].set val
      end

      @__attribute_param_of ||= {}
      if @__attribute_param_of[name] 
        unless @__attribute_param_of[name].config[:writable]
          private "#{name}="
        end

        if @__attribute_param_of[name].config[:handles]
          case @__attribute_param_of[name].config[:handles]
          when Hash
            @__attribute_param_of[name].config[:handles].each do |before, after|
              define_method before do
                attribute_of[name].get.__send__ after
              end
            end
          when Array
            @__attribute_param_of[name].config[:handles].each do |meth|
              define_method meth do
                attribute_of[name].get.__send__ meth
              end
            end
          end
        end
      end

    end

    alias has add_attribute

  end
end
