# frozen_string_literal: true

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
      files = Dir.glob(GraphqlTagPluck.options[:file_glob_pattern]).sort
      collector = HeredocCollector.new(GraphqlTagPluck.options[:graphql_heredoc_identifiers])

      {}.tap do |hash|
        files.each do |file|
          node = ::Parser::CurrentRuby.parse_file(file)
          next if node.nil?

          path = relative_path(file)

          collector.collect(node).each do |heredoc|
            GraphQL.parse(heredoc.source).definitions.each do |definition|
              line = heredoc.line + definition.line - 1
              # Unnamed operations are keyed by their location so keys stay stable across runs.
              key = definition.name || "#{path}:#{line}"

              if (existing = hash[key])
                raise Error, "Duplicate GraphQL definition name `#{key}`: " \
                  "defined at #{existing[:file]}:#{existing[:line]} and #{path}:#{line}"
              end

              hash[key] = {
                name: definition.name,
                source: definition.to_query_string,
                type: definition.instance_of?(GraphQL::Language::Nodes::FragmentDefinition) ? 'fragment' : definition.operation_type,
                file: path,
                line: line,
                constant: heredoc.constant
              }
            end
          end
        end
      end
    end

    private

    def relative_path(file)
      absolute = File.expand_path(file)
      prefix = "#{Dir.pwd}/"
      absolute.start_with?(prefix) ? absolute.delete_prefix(prefix) : absolute
    end
  end

  self.options = default_options.merge(Config.load)
end
