# frozen_string_literal: true

require_relative "graphql_tag_pluck/version"
require "parser/current"
require "graphql"

module GraphqlTagPluck
  require 'my_gem/railtie' if defined?(Rails)

  class Error < StandardError; end

  class << self

    def parse_file(file_path)
      file_string = File.read(file_path)
      Parser::CurrentRuby.parse(file_string)
    end

    def graphql_heredoc_identifiers
      %w{GRAPHQL GQL}
    end

    def is_graphql_heredoc_node?(node)
      node.loc.instance_of?(Parser::Source::Map::Heredoc) && graphql_heredoc_identifiers.any? {|identifier| node.loc.expression.source.include?(identifier) }
    end

    def parse_node(node)
      return nil unless node.respond_to?(:loc)
      return node.loc.heredoc_body.source if is_graphql_heredoc_node?(node)
      return node.children.map {|child| parse_node(child) } if node.respond_to?(:children)
    end

    def get_graphql_heredocs
      # want to make this path configurable
      files = Dir.glob("#{Dir.pwd}/**/*.rb")

      {}.tap do |hash|
        files.each do |file|
          node = parse_file(file)
          parse_node(node).flatten.compact.each do |graphql_doc_string|
            parsed_graphql_doc_string = GraphQL.parse(graphql_doc_string)
            hash[parsed_graphql_doc_string.definitions[0].name] = { 
              name: parsed_graphql_doc_string.definitions[0].name,
              source: parsed_graphql_doc_string.to_query_string,
              type: parsed_graphql_doc_string.definitions[0].operation_type
            }
          end
        end
      end
    end
  end
end
