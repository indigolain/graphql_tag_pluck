# GraphqlTagPluck

A gem for plucking GraphQL queries / mutations / fragments defined by heredocs inside files and exporting them to json file.
Install this gem and run the following rake task to get the exported json file containing the list of GraphQL queries / mutations / fragments.

```sh
bundle exec rake graphql_tag_pluck:generate_graphql_operation_list
```

You can configure the following options by creating `.graphqltagpluckconfig.yaml` and specifying them inside.

- graphql_heredoc_identifiers
  - An array of heredoc identifiers used to define GraphQL queries / mutations / fragments
  - default: `["GRAPHQL", "GQL"]`
- file_glob_pattern
  - A glob pattern to search for the heredocs containing GraphQL queries / mutations / fragments
  - default: `"#{Dir.pwd}/**/*.rb"`
- output_path
  - The destination of exported json file path
  - default: `"__generated__/graphql_operation_list.json"`

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
