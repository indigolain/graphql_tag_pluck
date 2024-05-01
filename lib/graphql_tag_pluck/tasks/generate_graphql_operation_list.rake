require 'fileutils'

namespace :graphql_tag_pluck do
  task :generate_graphql_operation_list do
    graphql_hash = GraphqlTagPluck.get_graphql_heredocs
    file_path = GraphqlTagPluck.options[:output_path]
    dirname = File.dirname(file_path)

    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    File.open(file_path, "w") do |f|
      f.write(graphql_hash.to_json)
    end
  end
end
