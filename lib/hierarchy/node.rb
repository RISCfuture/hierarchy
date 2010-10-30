module Hierarchy
  
  # A node in a tree structure. A node can have zero or more {#children}, and
  # has a reverse link back to its parent.

  class Node
    # @return [Array<Node>] This node's children.
    attr_reader :children

    # @return [Node, nil] This node's parent, or @nil@ if it is a root node.
    attr_reader :parent

    # @return The object this node contains.
    attr_accessor :content

    # Creates a new root node with no children.
    #
    # @param content The content the node will contain.

    def initialize(content)
      @children = []
      @content = content
    end

    # Adds a node as a child of this one. Sets the {#parent} of the given node.
    #
    # @param [Node] child The node to add as a child of this node.

    def <<(child)
      children << child
      child.instance_variable_set :@parent, self
    end

    # Performs a depth-first traversal using this as the root node of the tree.
    # @yield [node] Each node in depth-first order.
    # @yieldparam [Node] node A child node.

    def traverse(&block)
      children.each { |child| child.traverse &block }
      block[self]
    end

    # @private
    def inspect
      str = "#<#{self.class.to_s} #{content.inspect}"
      unless children.empty?
        str << ": [ #{children.map(&:inspect).join(', ')} ]"
      end
      str << ">"
      str
    end
  end
end
