require 'classx/attribute'
require 'classx/attributes'

class ClassX
  class InstanceException < Exception; end
  class AttrRequiredError < InstanceException; end
  class InvalidAttrArgument < InstanceException; end
  class LazyOptionShouldHaveDefault < Exception; end
  class OptionalAttrShouldBeWritable < Exception; end
  class RequiredAttrShouldNotHaveDefault < Exception; end

  extend Attributes

  def initialize *args
    hash = before_init(*args)

    unless hash && hash.kind_of?(Hash)
      raise ArgumentError, "#{hash.inspect} was wrong as arguments. please specify kind of Hash instance"
    end

    # allow String or Symbol for key 
    tmp_hash = {}
    hash.each do |key,val|
      tmp_hash[key.to_s] = val
    end
    hash = tmp_hash

    cached_attribute_of = attribute_of
    hash.each do |key, val|
      if cached_attribute_of[key]
        cached_attribute_of[key].set val
      end
    end

    cached_attribute_of.each do |key, val|
      next if val.class.lazy?
      raise AttrRequiredError, "param: :#{key} is required to #{hash.inspect}" if !val.class.optional? && !val.get
    end

    after_init
  end

  def attribute_of
    hash = {}
    private_methods.select {|meth| meth.to_s =~ ClassX::Attributes::ATTRIBUTE_REGEX }.each do |meth|
      meth.to_s =~ ClassX::Attributes::ATTRIBUTE_REGEX
      key = meth.to_s.sub(ClassX::Attributes::ATTRIBUTE_REGEX, $1)
      hash[key] = __send__ "attribute_of:#{key}"
    end

    hash
  end

  # just extend point
  def before_init *args
    raise ArgumentError if args.size > 1

    hash = args.first
    hash.nil? ? {} : hash
  end

  def after_init
  end

end
