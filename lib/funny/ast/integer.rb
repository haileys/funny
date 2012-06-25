module Funny::AST
  class Integer < Base
    attr_accessor :integer
    
    def inspect
      integer.inspect
    end
  end
end