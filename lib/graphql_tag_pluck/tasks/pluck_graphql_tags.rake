namespace :graphql_tag_pluck do
  task :generate_graphql_operation_list do
    graphql_hash = GraphqlTagPluck.get_graphql_heredocs
    File.open("__generated__/graphql_operation_list.json", "w") do |f|
      f.write(graphql_hash.to_json)
    end
  end
end
