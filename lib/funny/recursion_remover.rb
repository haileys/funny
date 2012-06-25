module Funny
  class RecursionRemover
    def self.transform(ast)
      rr = RecursionRemover.new ast
      ast.map { |n| rr.recursive?(n.name) ? transform_let(n) : n }
    end
    
    def self.transform_let(let_node)
      AST::Let.new name: let_node.name,
                   value: AST::Call.new(
                     callee: AST::Variable.new(name: "Y"),
                     argument: AST::Lambda.new(
                       argument: let_node.name,
                       body: let_node.value))
    end
    
    def initialize(ast)
      @globals = {}
      ast.each do |n|
        @globals[n.name] = n.value
      end
    end
    
    def recursive?(name)
      @shadowed = []
      @seen = {}
      @name = name
      analyze_node @globals[name]
    end
    
    def analyze_node(node)
      send node.class.name.split("::").last, node
    end
    
    def Integer(node)
      false
    end
    
    def Null(node)
      false
    end
    
    def Call(node)
      analyze_node node.callee or analyze_node node.argument
    end
    
    def Lambda(node)
      @shadowed << node.argument
      analyze_node(node.body).tap do
        @shadowed.pop
      end
    end
    
    def Variable(node)
      return true if node.name == @name
      if @globals[node.name] and not @shadowed.include? node.name
        return true if @seen[node.name]
        @seen[node.name] = true
        analyze_node @globals[node.name]
      end
    end
  end
end