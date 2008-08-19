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
  def initialize hash={}
    before_init hash

    unless hash && hash.kind_of?(Hash)
      raise ArgumentError, "#{hash.inspect} was wrong as arguments. please specify kind of Hash instance"
    end

    hash = hash.inject({}) {|h,item| h[item.first.to_s] = item.last; h } # allow String or Symbol for key 

    if respond_to? :attribute_of, true
      hash.each do |key, val|
        if attribute_of[key]
          attribute_of[key].set val
        end
      end

      attribute_of.each do |key, val|
        raise AttrRequiredError, "param: :#{key} is required to #{hash.inspect}" if !val.optional? && !val.get
      end
    end

    after_init
  end

  def attribute_of
    hash = {}
    private_methods.map {|meth| meth.to_s }.each do |meth|
      next unless meth =~ ClassX::Attributes::ATTRIBUTE_REGEX
      hash[$1] = __send__ "attribute_of:#$1"
    end

    hash
  end

  # just extend point
  def before_init hash
  end

  def after_init
  end

end
