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

### Loading the rake task

In a Rails app the task is available automatically. In any other project, add this to your `Rakefile`:

```ruby
require "graphql_tag_pluck/rake_tasks"
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

## Releasing

Releases are published to RubyGems.org by the [Release workflow](.github/workflows/release.yml) when a `v*` tag is pushed.

1. Bump `GraphqlTagPluck::VERSION` in `lib/graphql_tag_pluck/version.rb` and merge it into `main`.
2. Create a GitHub release for the matching tag:

   ```sh
   gh release create v$(ruby -r ./lib/graphql_tag_pluck/version -e 'print GraphqlTagPluck::VERSION') --target main --generate-notes
   ```

   (Pushing the tag yourself with `git tag vX.Y.Z && git push origin vX.Y.Z` works too.)

The workflow checks that the tag matches `VERSION`, runs the specs, then builds and pushes the gem.

One-time setup: on RubyGems.org, open the gem's **Trusted publishers** settings and add a GitHub Actions publisher with repository `indigolain/graphql_tag_pluck`, workflow `release.yml`, and environment `rubygems.org`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
