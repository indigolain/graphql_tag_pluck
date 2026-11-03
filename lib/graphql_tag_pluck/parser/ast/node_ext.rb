module GraphqlTagPluck
  module Parser
    module AST
      module NodeExt
        refine ::Parser::AST::Node do
          # Multi-line heredocs parse as :dstr even without interpolation, so
          # only parts other than plain strings (#{...}, #@ivar, ...) count.
          def interpolated?
            type == :dstr && children.any? { |child| child.type != :str && !(child.type == :dstr && !child.interpolated?) }
          end

          def is_graphql_heredoc_node?
            loc.instance_of?(::Parser::Source::Map::Heredoc) &&
              GraphqlTagPluck.options[:graphql_heredoc_identifiers].include?(heredoc_identifier)
          end

          # The terminator line holds the bare identifier, e.g. "GRAPHQL" for
          # <<~GRAPHQL, <<-'GRAPHQL' and <<"GRAPHQL" alike.
          def heredoc_identifier
            loc.heredoc_end.source.strip
          end
        end
      end
    end
  end
end
