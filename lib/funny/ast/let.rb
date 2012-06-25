module Funny::AST
  class Let < Base
    attr_accessor :name, :value
    
    def inspect
      "#{name} = #{value.inspect}"
    end
  end
end