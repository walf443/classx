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
    uniq_key = caller[0]
    unless @@__validate_cached[uniq_key]
      @@__validate_cached[uniq_key] = Class.new(ClassX)
      @@__validate_cached[uniq_key].class_eval &block
    end
    @@__validate_cached[uniq_key].new hash 
  end
end