# frozen_string_literal: true

require "json"
require "rake"
require "tmpdir"

RSpec.describe "graphql_tag_pluck/rake_tasks" do
  around do |example|
    original_application = Rake.application
    original_options = GraphqlTagPluck.options
    Rake.application = Rake::Application.new
    example.run
  ensure
    Rake.application = original_application
    GraphqlTagPluck.options = original_options
  end

  it "defines a task that writes the plucked operations to output_path" do
    load File.expand_path("../lib/graphql_tag_pluck/rake_tasks.rb", __dir__)

    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "a.rb"), <<~RUBY)
        Q = <<~GRAPHQL
          query FromRake { a }
        GRAPHQL
      RUBY
      output_path = File.join(dir, "out", "ops.json")
      GraphqlTagPluck.options = GraphqlTagPluck.options.merge(
        file_glob_pattern: File.join(dir, "**/*.rb"),
        output_path: output_path
      )

      Rake::Task["graphql_tag_pluck:generate_graphql_operation_list"].invoke

      expect(JSON.parse(File.read(output_path)).keys).to eq(["FromRake"])
    end
  end
end
