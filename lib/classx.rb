
class ClassX
  class AttrRequiredError < Exception; end
  class InvalidSetterArgument < Exception; end
  class LazyOptionShouldHaveDefault < Exception; end
  class <<self
    def has name, attrs={ :is => :ro, :required => false }
      name = name.to_s

      setter_definition = ''
      if !attrs[:respond_to].nil?
        setter_definition += <<-END_OF_RESPOND_TO
          raise InvalidSetterArgument, "param :#{name}'s value \#{val.inspect} should respond_to #{attrs[:respond_to]}}"  unless val.respond_to? #{attrs[:respond_to]}
        END_OF_RESPOND_TO
      end
      if !attrs[:kind_of].nil?
        setter_definition += <<-END_OF_KIND_OF
          raise InvalidSetterArgument, "param :#{name}'s value \#{val.inspect} should kind_of #{attrs[:kind_of]}" unless val.kind_of? #{attrs[:kind_of]}
        END_OF_KIND_OF
      end

      self.class_eval <<-END_OF_ACCESSOR
        attr_reader "#{name}"

        def #{name}= val
          #{setter_definition}
          @#{name} = val
        end
      END_OF_ACCESSOR

      if attrs[:is] == :ro
        __send__ :private,"#{name}="
      end

      if !attrs[:default].nil?
        case attrs[:default]
        when Proc
          register_attr_default_value_proc name, &attrs[:default]
        else
          register_attr_default_value name, attrs[:default]
        end
      else
        raise LazyOptionShouldHaveDefault, "in :#{name}: :lazy option need specifying :default" if attrs[:lazy]
      end

      if attrs[:required] 
        register_attr_required name
      end

    end

    def register_attr_default_value name, value
      self.class_eval do
        define_method "set_attr_default_value_of[#{name}]" do
          self.__send__ "#{name}=", value
        end

        private "set_attr_default_value_of[#{name}]"
      end
    end

    def register_attr_default_value_proc name, &block
      self.class_eval do
        define_method "set_attr_default_value_of[#{name}]" do
          self.__send__ "#{name}=", block.call(self)
        end

        private "set_attr_default_value_of[#{name}]"
      end
    end

    def register_attr_required name
      define_method "attr_required[#{name}]" do
      end

      private "attr_required[#{name}]"
    end
  end

  def initialize hash={}
    unless hash && hash.kind_of?(Hash)
      raise ArgumentError, "#{hash.inspect} was wrong as arguments of #{self.class}#initialize. please specify kind of Hash instance"
    end

    hash = hash.inject({}) {|h,item| h[item.first.to_s] = item.last; h } # allow String or Symbol for key 
    before_init
    required_attributes.each do |name|
      raise AttrRequiredError, "param :#{name} is required to initialize #{self.class}" unless hash.keys.include?(name)
    end
    hash.each do |key,val|
      __send__ "#{key}=", val
    end
    private_methods.select do |meth|
      meth.to_s =~ /^set_attr_default_value_of\[(.*?)\]$/
    end.each do |meth|
      __send__ meth
    end
    after_init
  end

  # just extend point
  def before_init
  end

  def after_init
  end

  private

  ATTR_REQUIRED_REGEX = /^attr_required\[(.*?)\]/
  def required_attributes
    private_methods.select {|meth|
      meth.to_s =~ ATTR_REQUIRED_REGEX
    }.map {|item|
      item.sub(ATTR_REQUIRED_REGEX) { $1 }
    }
  end
end
