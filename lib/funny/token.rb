module Funny
  class Token
    attr_accessor :type, :val, :line, :col
    
    def initialize(opts = {})
      opts.each do |k,v|
        send "#{k}=", v
      end
      raise "wtf!" unless line and col
    end
    
    def new_here(type)
      Token.new type: type, line: line, col: col
    end
  end
end