require "funny/token"
require "funny/lexer"
require "funny/parser"
require "funny/ast"
require "funny/error"
require "funny/recursion_remover"
require "funny/lambda_compiler"

module Funny
  STDLIB = File.expand_path("../funny/stdlib.fn", __FILE__)
  
  def self.parse(src)
    Funny::Parser.new(Funny::Lexer.new src).parse
  end
  
  def self.compile(src)
    ast = parse(File.read STDLIB) + parse(src)
    ast = Funny::RecursionRemover.transform ast
    compiler = Funny::LambdaCompiler.new ast
    compiler.compile
  end
end