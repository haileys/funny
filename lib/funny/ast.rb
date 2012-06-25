module Funny
  module AST
  end
end

require "funny/ast/base"
Dir[File.expand_path("../ast/*.rb", __FILE__)].each do |file|
  require file
end