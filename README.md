# GraphqlTagPluck

[![Gem Version](https://badge.fury.io/rb/graphql_tag_pluck.svg)](https://badge.fury.io/rb/graphql_tag_pluck)

A gem for plucking GraphQL queries / mutations / fragments defined by heredocs inside `.rb` files and exporting them into a json file.

Install this gem and run the following rake task to get the exported json file containing the list of GraphQL queries / mutations / fragments.

```sh
bundle exec rake graphql_tag_pluck:generate_graphql_operation_list
```

## Usage

With a sample heredoc like the following inside a `.rb` file:

```ruby
SAMPLE_QUERY = <<-GRAPHQL
  query SampleQuery {
    hoge
    fuga {
      piyo
    }
  }
GRAPHQL
```

will output json file like: (following json content is formatted)

```json
{
  "SampleQuery": {
    "name": "SampleQuery",
    "source": "query SampleQuery {\n  hoge\n  fuga {\n    piyo\n  }\n}",
    "type": "query"
  }
}
```

by executing

```sh
bundle exec rake graphql_tag_pluck:generate_graphql_operation_list
```

## Configuration

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

Install the gem and add to the application's Gemfile by executing:

```sh
$ bundle add graphql_tag_pluck
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
