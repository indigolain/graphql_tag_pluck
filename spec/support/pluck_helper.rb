# frozen_string_literal: true

require "fileutils"
require "tmpdir"

module PluckHelper
  # Writes the given { "relative/path.rb" => "source" } files into a temp dir
  # and runs GraphqlTagPluck against them.
  def pluck(files, options = {})
    Dir.mktmpdir do |dir|
      files.each do |name, content|
        path = File.join(dir, name)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content)
      end

      original_options = GraphqlTagPluck.options
      begin
        GraphqlTagPluck.options = original_options.merge(file_glob_pattern: File.join(dir, "**/*.rb")).merge(options)
        GraphqlTagPluck.get_graphql_heredocs
      ensure
        GraphqlTagPluck.options = original_options
      end
    end
  end
end
