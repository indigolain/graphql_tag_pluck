# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require './lib/graphql_tag_pluck'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

path = File.expand_path(__dir__)
Dir.glob("#{path}/lib/graphql_tag_pluck/tasks/**/*.rake").each { |f| import f }
