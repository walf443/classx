require 'classx/attributes'

class ClassX
  class InstanceException < Exception; end
  class AttrRequiredError < InstanceException; end
  class InvalidAttrArgument < InstanceException; end
  class LazyOptionShouldHaveDefault < Exception; end
  class OptionalAttrShouldBeWritable < Exception; end
  class RequiredAttrShouldNotHaveDefault < Exception; end

  ATTR_REGEX = /^([^=]*?)=$/
  SET_ATTR_DEFAULT_VALUE_REGEX = /^set_attr_default_value_of\[(.*?)\]$/
  ATTR_REQUIRED_REGEX = /^attr_required\[(.*?)\]/

  extend Attributes
  def initialize hash={}
    before_init hash

    unless hash && hash.kind_of?(Hash)
      raise ArgumentError, "#{hash.inspect} was wrong as arguments. please specify kind of Hash instance"
    end

    hash = hash.inject({}) {|h,item| h[item.first.to_s] = item.last; h } # allow String or Symbol for key 

    # set default value to attr
    private_methods.select do |meth|
      meth.to_s =~ SET_ATTR_DEFAULT_VALUE_REGEX
    end.each do |meth|
      __send__ meth
    end

    # check required attr in args
    self.class.required_attributes.each do |name|
      raise AttrRequiredError, "param :#{name} is required to #{hash.inspect}" unless hash.keys.include?(name)
    end

    # set value to attr
    hash.each do |key,val|
      if respond_to? "#{key}=", true
        __send__ "#{key}=", val
      end
    end

    after_init
  end

  # just extend point
  def before_init hash
  end

  def after_init
  end

end
