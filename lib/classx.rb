
class ClassX
  class AttrRequiredError < Exception; end
  class InvalidSetterArgument < Exception; end
  class InvalidAccessorType < Exception; end
  class LazyOptionShouldHaveDefault < Exception; end
  class <<self
    def has name, attrs={ :is => :ro, :required => false }
      __send__ :attr_accessor, name

      setter_definition = ''
      if !attrs[:respond_to].nil?
        setter_definition += <<-END_OF_RESPOND_TO
          raise InvalidAccessorType unless val.respond_to? #{attrs[:respond_to]}
        END_OF_RESPOND_TO
      end
      if !attrs[:kind_of].nil?
        setter_definition += <<-END_OF_KIND_OF
          raise InvalidAccessorType unless val.kind_of? #{attrs[:kind_of]}
        END_OF_KIND_OF
      end

      if !attrs[:default].nil?
        case attrs[:default]
        when Proc
          register_attr_default_value_proc name, &attrs[:default]
        else
          register_attr_default_value name, attrs[:default]
        end
      else
        raise LazyOptionShouldHaveDefault if attrs[:lazy]
      end

      if attrs[:required] 
        register_attr_required name
      end

      self.class_eval <<-END_OF_ACCESSOR
        attr_reader "#{name.to_s}"

        def #{name.to_s}= val
          #{setter_definition}
          @#{name.to_s} = val
        end
      END_OF_ACCESSOR

      if attrs[:is] == :ro
        __send__ :private,"#{name.to_s}="
      end
    end

    def register_attr_default_value name, value
      self.class_eval do
        define_method "set_attr_default_value_of[#{name.to_s}]" do
          self.__send__ "#{name.to_s}=", value
        end

        private "set_attr_default_value_of[#{name.to_s}]"
      end
    end

    def register_attr_default_value_proc name, &block
      self.class_eval do
        define_method "set_attr_default_value_of[#{name.to_s}]" do
          self.__send__ "#{name.to_s}=", block.call
        end

        private "set_attr_default_value_of[#{name.to_s}]"
      end
    end

    def register_attr_required name
      @@attr_required ||= {}
      @@attr_required[name] = true
    end
  end

  def initialize hash={}
    before_init
    @@attr_required.keys.each do |req|
      raise AttrRequiredError unless hash.keys.include?(req)
    end
    hash.each do |key,val|
      __send__ "#{key.to_s}=", val
    end
    methods.select do |meth|
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
end

if $0 == __FILE__
  class Point < ClassX
    has :x, :is => :ro, :kind_of => Fixnum, :default => 10
    has :y, :required => true
    has :hoge, :default => proc { "Hoge" }
  end
end
