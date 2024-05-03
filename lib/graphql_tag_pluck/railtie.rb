require 'rails'

module GraphqlTagPluck
  class Railtie < Rails::Railtie
    railtie_name :graphql_tag_pluck

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| puts f; load f }
    end
  end
end
