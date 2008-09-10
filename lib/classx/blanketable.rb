module ClassX
  # you can access class_attribute using Hash like interface.
  #   class YourClass
  #      include ClassX
  #      include ClassX::Blanketable
  #      has :x
  #   end
  #
  #   your = YourClass.new(:x => 20)
  #   your[:x] #=> 20
  #   your[:x] = 30
  #   your[:x] #=> 30
  module Blanketable
    def [] name
      if respond_to? name
        __send__ name
      else
        nil
      end
    end

    def []= name, val
      if respond_to? "#{name.to_s}"
        __send__ "#{name.to_s}=", val
      else
        raise RuntimeError
      end
    end
  end
end
