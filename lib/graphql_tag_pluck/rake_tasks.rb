# frozen_string_literal: true

# Defines the graphql_tag_pluck rake tasks outside Rails. Add this to your
# Rakefile:
#
#   require "graphql_tag_pluck/rake_tasks"
#
# Rails apps get the tasks through GraphqlTagPluck::Railtie and should not
# require this file, or the tasks will run twice.
require "graphql_tag_pluck"

Dir.glob(File.expand_path("tasks/**/*.rake", __dir__)).each { |f| load f }
