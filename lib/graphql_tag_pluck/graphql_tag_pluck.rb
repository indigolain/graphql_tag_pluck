# frozen_string_literal: true

module GraphqlTagPluck

  class Error < StandardError; end

  class << self
    using GraphqlTagPluck::Parser::AST::NodeExt

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
      unnamed_operation_count = 0

      {}.tap do |hash|
        files.each do |file|
          node = ::Parser::CurrentRuby.parse_file(file)
          parsed_node_array = node&.parse_node_recursively
          next if parsed_node_array.nil?

          parsed_node_array.flatten.compact.each do |graphql_doc_string|
            parsed_graphql_doc_string = GraphQL.parse(graphql_doc_string)
            parsed_graphql_doc_string.definitions.each do |definition|
              key = if definition.name.nil?
                unnamed_operation_count += 1
                "unnamed_operation_#{unnamed_operation_count}"
              else
                definition.name
              end

              hash[key] = { 
                name: definition.name,
                source: definition.to_query_string,
                type: definition.instance_of?(GraphQL::Language::Nodes::FragmentDefinition) ? 'fragment' : definition.operation_type 
              }
            end
          end
        end
      end
    end
  end

  self.options = default_options.merge(Config.load)
end
