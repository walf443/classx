# 
# for validatation Hash parameter declaretively.
#
#   require 'classx/validate'
#
#   class YourClass
#
#     def run params
#       validated_prams = Class::Validate.validate params do
#         has :x
#         has :y, :default => "hoge", :kind_of => Hash
#       end
#
#       # do something with params
#   
#     end
#   end
#
#   YourClass.new.run(:x => 10) # raise ClassX::AttrRequiredError
#
module ClassX::Validate
  private 
  def validate hash, options={}, &block #:doc:
    # FIXME: it's experimental feature for caching validate class.
    # it can use class variable because it use caller[0] as key.
    if options[:cache_key] != false
      options[:cache_key] = caller[0]
    end

    if ( options[:cache_key] )
      @@__validate_cached ||= {}
      klass = @@__validate_cached[options[:cache_key]]
    else
      klass = nil
    end

    unless klass
      klass = Class.new
      klass.class_eval do
        include ::ClassX
        include ::ClassX::Bracketable
      end
      klass.class_eval(&block)

      if options[:cache_key]
        @@__validate_cached[options[:cache_key]] = klass
      end
    end
    klass.new hash
  end

  module_function :validate
end
