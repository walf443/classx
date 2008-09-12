require 'classx/attribute'
require 'classx/attributes'

# usage
#
#   require 'classx'
#   class Point
#     include ClassX
#   
#     has :x, :kind_of => Fixnum
#     has :y, :kind_of => Fixnum
#   end
#   
#   class Point3D < Point
#     has :z, :writable => true, :kind_of => Fixnum, :optional => true
#   end
#   
#   Point.new(:x => 30, :y => 40)  #=> <# Point @x=30, @y=40 >
#   point3d = Point3D.new(:x => 30, :y => 40, :z => 50)  #=> <# Point3D @x=30, @y=40, @z=50 >
#   point3d.z = 60.0 # raise ClassX::InvalidAttrArgument
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

  # *args is Hash in default.
  # Hash should have attribute's key and valid value for attribute.
  # This method checking required value is setted and taking value is valid to attribute.
  #
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

  # return Hash of attribute's name as a key and attribute's meta class instance as a value.
  # for example, 
  #
  #   class YourClass
  #      include ClassX
  #      has :x
  #   end
  #
  #   obj = YourClass.new(:x => 10)
  #   obj.attribute_of    #=> { "x" => <#<ClassX::Attribute> parent=<# YourClass> ... > }
  #
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

  # processing initialize argument to hash
  # you can override this method for not taking initializer your classx based class.
  def before_init *args
    raise ArgumentError if args.size > 1

    hash = args.first
    hash.nil? ? {} : hash
  end

  alias process_init_args before_init

  # automatically called this method on last of #initialize.
  # you can override this method.
  def after_init
  end

  # shared implementation for comparing classx based object.
  def == other
    return false unless other.kind_of? self.class
    attribute_of.all? do |key, val|
      val.get == other.__send__(key)
    end
  end

  UNSERIALIZE_INSTANCE_VARIABLES = ["@__attribute_of", "@__attribute_data_of"]

  # convert attribute key and value to Hash.
  def to_hash
    result = {}

    attribute_of.each do |key, val|
      result[key] = val.get
    end

    result
  end

  # dupping classx based class.
  def dup
    self.class.new(to_hash)
  end

  # for Marshal.dump
  def marshal_dump
    dump_of = {}
    dump_of[:attribute_of] = to_hash
    dump_of[:instance_variable_of] = {}
    ( instance_variables.map {|ival| ival.to_s } - UNSERIALIZE_INSTANCE_VARIABLES ).each do |ival|
      dump_of[:instance_variable_of][ival] = instance_variable_get(ival)
    end

    dump_of
  end

  # for Marshal.load
  def marshal_load val
    self.attribute_of.each do |k, v|
      v.set(val[:attribute_of][k])
    end
    val[:instance_variable_of].each do |key, val|
      instance_variable_set(key, val)
    end
  end

  # for YAML.dump
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

  # for YAML.load
  def yaml_initialize tag, val
    self.attribute_of.each do |k, v|
      v.set(val[:attribute_of][k])
    end

    val[:instance_variable_of].each do |k, v|
      instance_variable_set(k, v)
    end
  end

  private

  def self.included klass
    klass.extend(Attributes)
  end

end
