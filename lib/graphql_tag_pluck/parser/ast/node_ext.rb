require "parser/current"

module GraphqlTagPluck
  module Parser
    module AST
      module NodeExt
        refine ::Parser::AST::Node do
          def parse_node_recursively
            return nil unless respond_to?(:loc)
            return loc.heredoc_body.source if is_graphql_heredoc_node?
            if respond_to?(:children)
              children.map {|child| child.respond_to?(:parse_node_recursively) ? child.parse_node_recursively : nil }
            end
          end

          def is_graphql_heredoc_node?
            loc.instance_of?(::Parser::Source::Map::Heredoc) &&
              GraphqlTagPluck.options[:graphql_heredoc_identifiers].any? {|identifier| loc.expression.source.include?(identifier) }
          end
        end
      end
    end
  end
end
