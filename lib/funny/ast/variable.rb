module Funny::AST
  class Variable < Base
    attr_accessor :name
    
    def inspect
      name
    end
  end
end