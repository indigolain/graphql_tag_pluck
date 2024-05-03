# frozen_string_literal: true

require "parser/current"
require "graphql"
require "yaml"

require_relative "graphql_tag_pluck/version"
require_relative "graphql_tag_pluck/config"
require_relative "graphql_tag_pluck/parser/ast/node_ext"
require_relative "graphql_tag_pluck/railtie" if defined?(Rails)

require_relative 'graphql_tag_pluck/graphql_tag_pluck'
