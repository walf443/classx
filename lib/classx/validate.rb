module ClassX::Validate
  private 
  # 
  # for validatation Hash parameter declaretively.
  #
  #   require 'classx/validate'
  #
  #   class YourClass < ClassX
  #     include Validate
  #
  #     def run params
  #       validate params do
  #         has :x, :requried => true
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
  def validate hash, &block
    # FIXME: it's experimental feature for caching validate class.
    # it can use class variable because it use caller[0] as key.
    @@__validate_cached ||= {} 
    klass = @@__validate_cached[caller[0]] ||= Class.new(ClassX)

    klass.class_eval &block
    klass.new hash 
  end
end
