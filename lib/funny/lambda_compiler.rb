module Funny
  class LambdaCompiler
    def initialize(ast)
      @globals = {}
      @replacements = Hash.new { |h,k| h[k] = "x#{h.size.to_s 36}" }
      @ast = ast
      @non_globals = []
    end
    
    def compile
      @ast.each do |n|
        @globals[n.name] = n.value
      end
      main = @ast.select { |n| n.name == "main" }.first
      "main = #{compile_node main.value}"
    end
    
    def compile_node(node)
      send node.class.name.split("::").last, node
    end
    
    def ruby_name(name)
      if /\A[a-z][a-z0-9]*\z/i =~ name
        name
      else
        @replacements[name]
      end
    end

    def Call(node)
      "#{compile_node node.callee}[#{compile_node node.argument}]"
    end
    
    def Integer(node)
      raise "Non-natural numbers not supported" if node.integer < 0
      body = "x"
      node.integer.times { body = "p[#{body}]" }
      "->p{->x{#{body}}}"
    end
    
    def Lambda(node)
      @non_globals << node.argument
      "->#{ruby_name node.argument || "*"}{#{compile_node node.body}}".tap do
        @non_globals.pop
      end
    end
    
    def Null(node)
      compile_node AST::Variable.new(name: "nullList")
    end
    
    def Variable(node)
      if @non_globals.include? node.name
        ruby_name node.name
      elsif @globals[node.name]
        compile_node @globals[node.name]
      else
        raise "Undefined identifier #{node.name}"
      end
    end
  end
end