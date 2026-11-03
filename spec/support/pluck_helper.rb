# frozen_string_literal: true

require "fileutils"
require "tmpdir"

module PluckHelper
  # Writes the given { "relative/path.rb" => "source" } files into a temp dir
  # and runs GraphqlTagPluck against them.
  def pluck(files, options = {})
    in_project(files) { |dir| pluck_with_options(dir, options) }
  end

  # Like #pluck, but runs from inside the temp dir, as the rake task does from
  # a project root, so reported file paths are relative.
  def pluck_from_project_root(files, options = {})
    in_project(files) { |dir| Dir.chdir(dir) { pluck_with_options(dir, options) } }
  end

  private

  def in_project(files)
    Dir.mktmpdir do |dir|
      files.each do |name, content|
        path = File.join(dir, name)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content)
      end

      yield dir
    end
  end

  def pluck_with_options(dir, options)
    original_options = GraphqlTagPluck.options
    begin
      GraphqlTagPluck.options = original_options.merge(file_glob_pattern: File.join(dir, "**/*.rb")).merge(options)
      GraphqlTagPluck.get_graphql_heredocs
    ensure
      GraphqlTagPluck.options = original_options
    end
  end
end
