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
      # Sorted so the output, and which duplicate wins, does not depend on file system order.
      files = Dir.glob(GraphqlTagPluck.options[:file_glob_pattern]).sort
      collector = HeredocCollector.new

      {}.tap do |hash|
        files.each do |file|
          node = begin
            RubyParser.parse_file(file)
          rescue ::Parser::SyntaxError => e
            warn "graphql_tag_pluck: skipping #{file}, which could not be parsed as Ruby: #{e.message}"
            next
          end
          next if node.nil?

          path = relative_path(file)

          collector.collect(node).each do |heredoc|
            document = begin
              GraphQL.parse(heredoc.source)
            rescue GraphQL::ParseError => e
              warn "graphql_tag_pluck: skipping invalid GraphQL heredoc in #{path}:#{heredoc.line}: #{e.message}"
              next
            end

            document.definitions.each do |definition|
              line = heredoc.line + definition.line - 1
              # Unnamed operations are keyed by their location so keys stay stable across runs.
              key = definition.name || "#{path}:#{line}"
              source = definition.to_query_string

              # Operation names must be unique, even for identical copies, so the
              # generated list never silently depends on which definition wins.
              if (existing = hash[key])
                raise Error, "Duplicate GraphQL definition name `#{key}`: " \
                  "defined at #{existing[:file]}:#{existing[:line]} and #{path}:#{line}"
              end

              hash[key] = {
                name: definition.name,
                source: source,
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

    # Relative to the current directory when the file is inside it, absolute otherwise.
    def relative_path(file)
      absolute = File.realpath(file)
      prefix = "#{File.realpath(Dir.pwd)}/"
      absolute.start_with?(prefix) ? absolute.delete_prefix(prefix) : absolute
    end
  end

  self.options = default_options.merge(Config.load)
end
