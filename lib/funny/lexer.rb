module Funny
  class Lexer
    TOKENS = [
      [ :LINE_TERMINATOR, "\n" ],
      [ :COMMENT,         /#.*?$/ ],
      [ :WHITESPACE,      /\s/ ],
      [ :BAREWORD,        /((?<v>[a-z_][a-z0-9_]*)|`(?<v>[^`]+)`)/i, ->m { m[:v] } ],
      [ :INTEGER,         /[0-9]+/, ->m { m[0].to_i } ],
      [ :FLOAT,           /[0-9]+\.[0-9]+/, ->m { m[0].to_f } ],
      [ :OPEN_PAREN,      "(" ],
      [ :CLOSE_PAREN,     ")" ],
      [ :PLUS,            "+" ],
      [ :LAMBDA,          "->" ],
      [ :MINUS,           "-" ],
      [ :MOD,             "%" ],
      [ :POWER,           "**" ],
      [ :ASTERISK,        "*" ],
      [ :SLASH,           "/" ],
      [ :LTE,             "<=" ],
      [ :GTE,             ">=" ],
      [ :LT,              "<" ],
      [ :GT,              ">" ],
      [ :EQ,              "==" ],
      [ :EQUALS,          "=" ],
      [ :AND,             "&&" ],
      [ :OR,              "||" ],
      [ :NOT,             "!" ],
      [ :COMMA,           "," ],
      [ :COLON,           ":" ],
      [ :OPEN_BRACKET,    "[" ],
      [ :CLOSE_BRACKET,   "]" ]
    ].map do |name,rule,lambda|
      case rule
      when String
        [name, ->s { s[0...rule.size] == rule and [nil, s[rule.size..-1]] }]
      when Regexp
        rule = Regexp.new("\\A#{rule.source}", rule.options | 4)
        lambda ||= ->*{}
        [name, ->s { m = rule.match(s) and [lambda.call(m), m.post_match] }]
      when Proc
        [name, rule]
      end
    end
    
    def initialize(str)
      @str = str
      @indents = [0]
      @token_queue = []
      @line = 1
      @col = 0
    end
    
    def next_token
      token = next_raw_token
      if [:WHITESPACE, :COMMENT, :LINE_TERMINATOR].include? token.type
        return next_token
      end
      token
    end
    
  private
    def error!(message)
      raise Funny::Error, message
    end

    def next_raw_token
      return Token.new(type: :END, line: @line, col: @col) if @str.empty?
      TOKENS.each do |name,rule|
        if retn = rule.call(@str)
          match, post = retn
          matched = @str[0, @str.size - post.size]
          @str = post
          @line += matched.count "\n"
          if matched.include? "\n"
            @col = matched.size - matched.rindex("\n")
          else
            @col += matched.size
          end
          return Token.new type: name, val: match, col: @col, line: @line
        end
      end
      error! "unexpected character '#{@str[0]}'"
    end
  end
end