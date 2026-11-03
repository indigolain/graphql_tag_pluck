# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-11-03

### Added

- Each exported entry now records where it was defined: `file` (relative to
  the current directory, or absolute for files outside it), `line` (the line
  the definition starts on, also correct for several definitions in one
  heredoc), and `constant` (the fully qualified constant the heredoc is
  assigned to, such as `Clients::UserClient::USER_QUERY`, or `null`).
  ([#16](https://github.com/indigolain/graphql_tag_pluck/pull/16))

### Changed

- **Breaking:** unnamed operations are keyed by their location, such as
  `"app/clients/user_client.rb:4"`, instead of `unnamed_operation_N`. The old
  counter depended on the order files were read in.
  ([#16](https://github.com/indigolain/graphql_tag_pluck/pull/16))
- **Breaking:** any definition name that appears more than once, even with an
  identical definition, now raises `GraphqlTagPluck::Error` naming both
  locations, and no output file is written. 0.2.0 only warned and kept the
  last definition.
  ([#16](https://github.com/indigolain/graphql_tag_pluck/pull/16))
- Files are processed in sorted order, so output no longer depends on file
  system order. Warnings for invalid GraphQL now include the `path:line`.
  ([#16](https://github.com/indigolain/graphql_tag_pluck/pull/16))

## [0.2.0] - 2026-11-03

### Changed

- Heredoc identifiers are now matched exactly. Previously, any heredoc whose
  identifier merely *contained* a configured one was treated as GraphQL, so
  `<<~NOT_GRAPHQL_DOC` matched `GRAPHQL` and `QL` matched `GRAPHQL`. If you
  relied on that, list each identifier in `graphql_heredoc_identifiers`.
  ([#2](https://github.com/indigolain/graphql_tag_pluck/pull/2))
- A Ruby file with a syntax error, or a heredoc that is not valid GraphQL, is
  now skipped with a warning instead of aborting the whole run.
  ([#4](https://github.com/indigolain/graphql_tag_pluck/pull/4))
- On Ruby 3.3 and later, files are parsed with Prism's parser translation
  instead of the `parser` gem. It understands the running Ruby's syntax and no
  longer prints "parser/current is loading parser/ruby33" warnings. Older Rubies
  still use the `parser` gem. This adds a dependency on `prism` (>= 1.8) and
  requires `parser` >= 3.3.7.2.
  ([#13](https://github.com/indigolain/graphql_tag_pluck/pull/13))

### Added

- `require "graphql_tag_pluck/rake_tasks"` loads the rake task in projects that
  don't use Rails.
  ([#9](https://github.com/indigolain/graphql_tag_pluck/pull/9))
- A warning when two different definitions share an operation name, naming both
  files. The last definition still wins, as before.
  ([#5](https://github.com/indigolain/graphql_tag_pluck/pull/5))

### Fixed

- GraphQL heredocs that use Ruby interpolation (`#{...}`, `#@ivar`) crashed the
  run. They are now skipped with a warning that gives their location, since
  their final text is only known at runtime.
  ([#3](https://github.com/indigolain/graphql_tag_pluck/pull/3))
- An empty `.graphqltagpluckconfig.yaml` raised an error instead of using the
  defaults.
- In Rails apps, loading rake tasks (for example, any `rake` command) printed
  the gem's rake file paths.
  ([#6](https://github.com/indigolain/graphql_tag_pluck/pull/6))

## [0.1.1] - 2024-05-01

### Fixed

- Unnamed operations (such as `query { ... }`) all shared one `null` key and
  overwrote each other. They are now exported as `unnamed_operation_1`,
  `unnamed_operation_2`, and so on.

## [0.1.0] - 2024-05-01

### Added

- Initial release: plucks GraphQL queries, mutations and fragments from Ruby
  heredocs and exports them to a JSON file with the
  `graphql_tag_pluck:generate_graphql_operation_list` rake task.
- Configuration through `.graphqltagpluckconfig.yaml`
  (`graphql_heredoc_identifiers`, `file_glob_pattern`, `output_path`).

[Unreleased]: https://github.com/indigolain/graphql_tag_pluck/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/indigolain/graphql_tag_pluck/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/indigolain/graphql_tag_pluck/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/indigolain/graphql_tag_pluck/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/indigolain/graphql_tag_pluck/releases/tag/v0.1.0
