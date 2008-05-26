module ClassX::Validate
  private 
  # 
  # for validatation Hash parameter declaretively.
  #
  # require 'classx/validate'
  #
  # class YourClass < ClassX
  #   include Validate
  #
  #   def run params
  #     classx_instance = validate params do
  #       has :x, :requried => true
  #       has :y, :default => "hoge", :kind_of => Hash
  #     end
  #
  #     # do something
  #
  def validate hash, &block
    klass = Class.new(ClassX)
    klass.class_eval &block
    klass.new hash 
  end
end
