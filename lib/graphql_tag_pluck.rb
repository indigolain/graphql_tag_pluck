# frozen_string_literal: true

require_relative "graphql_tag_pluck/version"
require_relative "graphql_tag_pluck/config"
require_relative "graphql_tag_pluck/lib/railtie" if defined?(Rails)
require "parser/current"
require "graphql"

module GraphqlTagPluck

  class Error < StandardError; end

  class << self
    attr_accessor :options

    def default_options
      {
        graphql_heredoc_identifiers: %w{GRAPHQL GQL},
        file_glob_pattern: "#{Dir.pwd}/**/*.rb",
        output_path: "__generated__/graphql_operation_list.json"
      }
    end

    def get_graphql_heredocs
      files = Dir.glob(GraphqlTagPluck.options[:file_glob_pattern])

      {}.tap do |hash|
        files.each do |file|
          node = create_node_from_file(file)
          parse_node_recursively(node).flatten.compact.each do |graphql_doc_string|
            parsed_graphql_doc_string = GraphQL.parse(graphql_doc_string)
            parsed_graphql_doc_string.definitions.each do |definition|
              hash[definition.name] = { 
                name: definition.name,
                source: definition.to_query_string,
                type: definition.instance_of?(GraphQL::Language::Nodes::FragmentDefinition) ? 'fragment' : definition.operation_type 
              }
            end
          end
        end
      end
    end

    def create_node_from_file(file_path)
      file_string = File.read(file_path)
      Parser::CurrentRuby.parse(file_string)
    end

    def parse_node_recursively(node)
      return nil unless node.respond_to?(:loc)
      return node.loc.heredoc_body.source if is_graphql_heredoc_node?(node)
      return node.children.map {|child| parse_node_recursively(child) } if node.respond_to?(:children)
    end

    def is_graphql_heredoc_node?(node)
      node.loc.instance_of?(Parser::Source::Map::Heredoc) &&
        GraphqlTagPluck.options[:graphql_heredoc_identifiers].any? {|identifier| node.loc.expression.source.include?(identifier) }
    end
  end

  self.options = default_options.merge(Config.load)
end
