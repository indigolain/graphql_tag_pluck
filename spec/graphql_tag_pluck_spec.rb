# frozen_string_literal: true

RSpec.describe GraphqlTagPluck do
  it "has a version number" do
    expect(GraphqlTagPluck::VERSION).not_to be nil
  end

  describe ".get_graphql_heredocs" do
    def pluck(fixture_dir)
      root = File.expand_path("fixtures/#{fixture_dir}", __dir__)
      original = GraphqlTagPluck.options
      GraphqlTagPluck.options = original.merge(file_glob_pattern: "#{root}/**/*.rb")
      Dir.chdir(root) { GraphqlTagPluck.get_graphql_heredocs }
    ensure
      GraphqlTagPluck.options = original
    end

    subject(:result) { pluck("app") }

    it "records file, line, and namespaced constant of each definition" do
      expect(result["UserQuery"]).to include(
        name: "UserQuery",
        type: "query",
        file: "clients/user_client.rb",
        line: 4,
        constant: "Clients::UserClient::USER_QUERY"
      )
    end

    it "computes the line of each definition inside a heredoc with several definitions" do
      expect(result["UserFields"]).to include(type: "fragment", line: 10, constant: "Clients::UserClient::USER_QUERY")
    end

    it "resolves top-level constant assignments" do
      expect(result["UpdateUser"]).to include(type: "mutation", line: 17, constant: "TOP_LEVEL_MUTATION")
    end

    it "leaves constant nil for heredocs not assigned to a constant" do
      expect(result["InlineQuery"]).to include(line: 24, constant: nil)
    end

    it "keys unnamed operations by file and line" do
      expect(result["unnamed.rb:4"]).to include(name: nil, type: "query", constant: "UNNAMED")
    end

    it "ignores heredocs with other identifiers" do
      expect(result.keys).to contain_exactly("UserQuery", "UserFields", "UpdateUser", "InlineQuery", "unnamed.rb:4")
    end

    it "raises on duplicate definition names" do
      expect { pluck("duplicates") }.to raise_error(
        GraphqlTagPluck::Error,
        "Duplicate GraphQL definition name `Same`: defined at a.rb:2 and b.rb:2"
      )
    end
  end
end
