require 'classx/attribute'
require 'classx/attributes'

module ClassX
  autoload :Validate,    'classx/validate'
  autoload :Commandable, 'classx/commandable'
  autoload :Declare,     'classx/declare'
  module Role
    autoload :Logger,    'classx/role/logger'
  end

  class InstanceException < Exception; end
  class AttrRequiredError < InstanceException; end
  class InvalidAttrArgument < InstanceException; end
  class LazyOptionShouldHaveDefault < Exception; end
  class OptionalAttrShouldBeWritable < Exception; end
  class RequiredAttrShouldNotHaveDefault < Exception; end

  def self.included klass
    klass.extend(Attributes)
  end

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

    hash.each do |key, val|
      if attribute_of[key]
        attribute_of[key].set val
      end
    end

    attribute_of.each do |key, val|
      next if val.class.lazy?
      raise AttrRequiredError, "param: :#{key} is required to #{hash.inspect}" if !val.class.optional? && !val.get
    end

    after_init
  end

  def attribute_of
    unless instance_variable_defined?('@__attribute_of') && @__attribute_of
      @__attribute_of = {}
      if self.class.attribute_of
        self.class.attribute_of.keys.each do |key|
          @__attribute_of[key] = __send__ "attribute_of:#{key}"
        end
      end
    end

    @__attribute_of
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
