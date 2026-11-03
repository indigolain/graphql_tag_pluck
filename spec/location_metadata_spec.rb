# frozen_string_literal: true

RSpec.describe GraphqlTagPluck, "location metadata" do
  subject(:result) { pluck_from_project_root(files) }

  let(:files) do
    {
      "app/clients/user_client.rb" => <<~'RUBY',
        module Clients
          class UserClient
            USER_QUERY = <<~GRAPHQL.freeze
              query UserQuery($id: ID!) {
                user(id: $id) {
                  ...UserFields
                }
              }

              fragment UserFields on User {
                id
                name
              }
            GRAPHQL

            ::TOP_LEVEL_MUTATION = <<~GQL
              mutation UpdateUser {
                updateUser { id }
              }
            GQL

            Nested::SCOPED_QUERY = <<~GRAPHQL
              query ScopedQuery { a }
            GRAPHQL

            def call
              execute(<<~GRAPHQL)
                query InlineQuery {
                  viewer { id }
                }
              GRAPHQL
            end
          end
        end
      RUBY
      "app/unnamed.rb" => <<~'RUBY'
        # a comment so the heredoc body does not start on line 2

        UNNAMED = <<~GRAPHQL
          {
            viewer { id }
          }
        GRAPHQL
      RUBY
    }
  end

  it "records the file relative to the current directory, the line, and the namespaced constant" do
    expect(result["UserQuery"]).to include(
      name: "UserQuery",
      type: "query",
      file: "app/clients/user_client.rb",
      line: 4,
      constant: "Clients::UserClient::USER_QUERY"
    )
  end

  it "computes the line of each definition in a heredoc with several definitions" do
    expect(result["UserFields"]).to include(type: "fragment", line: 10, constant: "Clients::UserClient::USER_QUERY")
  end

  it "resolves top-level and scoped constant assignments" do
    expect(result["UpdateUser"]).to include(type: "mutation", line: 17, constant: "TOP_LEVEL_MUTATION")
    expect(result["ScopedQuery"]).to include(constant: "Clients::UserClient::Nested::SCOPED_QUERY")
  end

  it "leaves constant nil for heredocs not assigned to a constant" do
    expect(result["InlineQuery"]).to include(line: 28, constant: nil)
  end

  it "keys unnamed operations by file and line" do
    expect(result["app/unnamed.rb:4"]).to include(name: nil, type: "query", file: "app/unnamed.rb", line: 4, constant: "UNNAMED")
  end

  it "uses absolute paths for files outside the current directory" do
    expect(pluck(files)["UserQuery"][:file]).to end_with("/app/clients/user_client.rb").and start_with("/")
  end
end
