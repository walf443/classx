module ClassX
  # you can access attribute using Hash like interface.
  #   class YourClass
  #      include ClassX
  #      include ClassX::Bracketable
  #      has :x
  #   end
  #
  #   your = YourClass.new(:x => 20)
  #   your[:x] #=> 20
  #   your[:x] = 30
  #   your[:x] #=> 30
  #
  # you can also use for class attribute
  #
  #   class YourClass
  #      extend ClssX::CAttrs
  #      extend ClassX::Bracketable
  #
  #      class_has :x
  #   end
  #
  #   YourClass[:x] = 20
  #   YourClass[:x] #=> 20
  #
  module Bracketable
    def [] name
      attr_meth = nil
      if respond_to? :class_attribute_of, true
        attr_meth = :class_attribute_of
      elsif respond_to? :attribute_of, true
        attr_meth = :attribute_of
      else
        return nil
      end

      if __send__(attr_meth).keys.include? name.to_s
        __send__ name
      else
        nil
      end
    end

    def []= name, val
      attr_meth = nil
      if respond_to? :class_attribute_of, true
        attr_meth = :class_attribute_of
      elsif respond_to? :attribute_of, true
        attr_meth = :attribute_of
      else
        return nil
      end

      if __send__(attr_meth).keys.include?(name.to_s) && respond_to?("#{name.to_s}=")
        __send__ "#{name.to_s}=", val
      else
        raise NoMethodError, ":#{name} is private, or missing"
      end
    end
  end
end
