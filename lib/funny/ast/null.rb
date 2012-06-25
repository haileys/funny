module Funny::AST
  class Null < Base
    def inspect
      "[]"
    end
  end
end