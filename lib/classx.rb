require 'classx/attribute'
require 'classx/attributes'

module ClassX
  autoload :ClassAttributes, 'classx/class_attributes'
  autoload :CAttrs,          'classx/class_attributes'
  autoload :Validate,    'classx/validate'
  autoload :Commandable, 'classx/commandable'
  autoload :Declare,     'classx/declare'
  autoload :Bracketable, 'classx/bracketable'
  module Role
    autoload :Logger,    'classx/role/logger'
  end

  MODULE_USAGE_MAP_OF = {
    :ClassAttributes => :extend,
    :CAttrs => :extend,
    :Commandable => :extend,
    :Declare     => :extend,
    :Bracketable => :include,
    :Validate => :include,
  }

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

  def == other
    return false unless other.kind_of? self.class
    attribute_of.all? do |key, val|
      val.get == other.__send__(key)
    end
  end

  UNSERIALIZE_INSTANCE_VARIABLES = ["@__attribute_of", "@__attribute_data_of"]
  def to_hash
    result = {}

    attribute_of.each do |key, val|
      result[key] = val.get
    end

    result
  end

  def dup
    self.class.new(to_hash)
  end

  def marshal_dump
    dump_of = {}
    dump_of[:attribute_of] = to_hash
    dump_of[:instance_variable_of] = {}
    ( instance_variables.map {|ival| ival.to_s } - UNSERIALIZE_INSTANCE_VARIABLES ).each do |ival|
      dump_of[:instance_variable_of][ival] = instance_variable_get(ival)
    end

    dump_of
  end

  def marshal_load val
    self.attribute_of.each do |k, v|
      v.set(val[:attribute_of][k])
    end
    val[:instance_variable_of].each do |key, val|
      instance_variable_set(key, val)
    end
  end

  def to_yaml opts={}
    require 'yaml'
    YAML.quick_emit(self, opts) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        attribute_of = {}
        to_hash.each do |key, val|
          attribute_of[key] = val
        end
        map.add(:attribute_of, attribute_of)

        instance_variable_of = {}
        ( instance_variables.map {|ival| ival.to_s } - UNSERIALIZE_INSTANCE_VARIABLES ).each do |ival|
          instance_variable_of[ival] = instance_variable_get(ival)
        end
        map.add(:instance_variable_of, instance_variable_of)
      end
    end
  end

  def yaml_initialize tag, val
    self.attribute_of.each do |k, v|
      v.set(val[:attribute_of][k])
    end

    val[:instance_variable_of].each do |k, v|
      instance_variable_set(k, v)
    end
  end

end
