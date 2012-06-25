module Funny::AST
  class Lambda < Base
    attr_accessor :argument, :body
    
    def inspect
      "#{argument} -> #{body.inspect}"
    end
  end
end