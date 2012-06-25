module Funny
  class Parser
    def initialize(lexer)
      @lexer = lexer
    end
    
    def parse
      [].tap do |nodes|
        while peek_token.type != :END
          nodes << top_level_statement
        end
      end
    end
    
  private
    def token
      @token
    end
    
    def peek_token
      return @peek_token if @peek_token
      @peek_token = @lexer.next_token
    end
    
    def next_token
      if @peek_token
        @token, @peek_token = @peek_token, nil
        token
      else
        @token = @lexer.next_token
      end
    end
    
    def expect_token(*types)
      next_token.tap do |token|
        error! "Unexpected #{token.type}" unless types.include? token.type
      end
    end
    
    def error!(message)
      raise Funny::Error, "#{message} at line #{(token || peek_token).line}, col #{(token || peek_token).col}"
    end
    
    def top_level_statement
      function_declaration
    end
    
    def function_declaration
      expect_token :BAREWORD
      name = token.val
      args = []
      expect_token :OPEN_PAREN, :EQUALS
      if token.type == :OPEN_PAREN
        while peek_token.type != :CLOSE_PAREN
          expect_token :BAREWORD
          args << token.val
          break if peek_token.type == :CLOSE_PAREN
          expect_token :COMMA
        end
        expect_token :CLOSE_PAREN
        expect_token :EQUALS
      end
      body = args.reverse_each.reduce(expression) { |a,b| AST::Lambda.new argument: b, body: a }
      AST::Let.new name: name, value: body
    end
    
    def expression
      or_expression
    end
    
    def or_expression
      left = and_expression
      if peek_token.type == :OR
        next_token
        left = make_curried_call "||", left, and_expression
      end
      left
    end
    
    def and_expression
      left = relational_expression
      if peek_token.type == :AND
        next_token
        left = make_curried_call "&&", left, relational_expression
      end
      left
    end
    
    def relational_expression
      left = cons_expression
      if [:LT, :LTE, :GT, :GTE, :EQ].include? peek_token.type
        fn =  case next_token.type
              when :LT; "<"
              when :LTE; "<="
              when :GT; ">"
              when :GTE; ">="
              when :EQ; "=="
              end
        left = make_curried_call fn, left, cons_expression
      end
      left
    end
    
    def cons_expression
      left = additive_expression
      if peek_token.type == :COLON
        next_token
        left = make_curried_call ":", left, cons_expression
      end
      left
    end
    
    def additive_expression
      left = multiplicative_expression
      while [:PLUS, :MINUS].include? peek_token.type
        fn =  case next_token.type
              when :PLUS; "+"
              when :MINUS; "-"
              end
        left = make_curried_call fn, left, multiplicative_expression
      end
      left
    end
    
    def multiplicative_expression
      left = negate_expression
      while [:ASTERISK, :SLASH, :MOD].include? peek_token.type
        fn =  case next_token.type
              when :ASTERISK; "*"
              when :SLASH; "/"
              when :MOD; "%"
              end
        left = make_curried_call fn, left, negate_expression
      end
      left
    end
    
    def negate_expression
      if peek_token.type == :MINUS
        next_token
        make_curried_call "negate", power_expression
      else
        power_expression
      end
    end
    
    def power_expression
      left = unary_expression
      if peek_token.type == :POWER
        next_token
        make_curried_call "**", left, power_expression
      else
        left
      end
    end
    
    def unary_expression
      if peek_token.type == :NOT
        next_token
        make_curried_call "!", unary_expression
      else
        call_expression
      end
    end
    
    def call_expression
      left = primary_expression
      while peek_token.type == :OPEN_PAREN
        next_token
        while peek_token.type != :CLOSE_PAREN
          left = AST::Call.new callee: left, argument: expression
          break if peek_token.type == :CLOSE_PAREN
          expect_token :COMMA
        end
        expect_token :CLOSE_PAREN
      end
      left
    end
    
    def primary_expression
      case peek_token.type
      when :BAREWORD;     variable
      when :INTEGER;      integer
      when :OPEN_PAREN;   bracketed_expression
      when :LAMBDA;       lambda(nil)
      when :OPEN_BRACKET; list
      else error! "Unexpected #{peek_token.type}"
      end
    end
    
    def list
      expect_token :OPEN_BRACKET
      elements = []
      while peek_token.type != :CLOSE_BRACKET
        elements << expression
        break if peek_token.type == :CLOSE_BRACKET
        expect_token :COMMA
      end
      expect_token :CLOSE_BRACKET
      elements.reverse_each.inject(AST::Null.new) { |a,b| make_curried_call ":", b, a }
    end
    
    def lambda(argument)
      expect_token :LAMBDA
      AST::Lambda.new argument: argument, body: expression
    end
    
    def bracketed_expression
      expect_token :OPEN_PAREN
      expression.tap do
        expect_token :CLOSE_PAREN
      end
    end
    
    def variable
      expect_token :BAREWORD
      var = AST::Variable.new name: token.val
      if peek_token.type == :LAMBDA
        lambda var.name
      else
        var
      end
    end
    
    def integer
      expect_token :INTEGER
      AST::Integer.new integer: token.val
    end
    
    def make_curried_call(name, *args)
      args.inject(AST::Variable.new(name: name)) { |a,b| AST::Call.new callee: a, argument: b }
    end
  end
end