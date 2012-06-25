module Funny::AST
  class Base
    def initialize(opts = {})
      opts.each do |k,v|
        send "#{k}=", v
      end
      yield self if block_given?
    end
  end
end