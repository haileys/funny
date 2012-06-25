module Funny::AST
  class Call < Base
    attr_accessor :callee, :argument
    
    def inspect
      "#{callee.inspect}(#{argument.inspect})"
    end
  end
end