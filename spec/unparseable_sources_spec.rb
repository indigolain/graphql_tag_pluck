# frozen_string_literal: true

RSpec.describe GraphqlTagPluck, "unparseable sources" do
  let(:valid_file) do
    <<~RUBY
      Q = <<~GRAPHQL
        query Valid { a }
      GRAPHQL
    RUBY
  end

  it "skips Ruby files with syntax errors and keeps the rest" do
    result = nil
    expect do
      result = pluck("broken.rb" => "def oops(\n", "valid.rb" => valid_file)
    end.to output(%r{skipping .*/broken\.rb, which could not be parsed as Ruby}).to_stderr

    expect(result.keys).to eq(["Valid"])
  end

  it "skips heredocs that are not valid GraphQL and keeps the rest" do
    invalid = <<~RUBY
      Q = <<~GRAPHQL
        query Broken {
      GRAPHQL
      R = <<~GRAPHQL
        query AlsoValid { b }
      GRAPHQL
    RUBY

    result = nil
    expect do
      result = pluck("invalid.rb" => invalid, "valid.rb" => valid_file)
    end.to output(%r{skipping invalid GraphQL heredoc in .*/invalid\.rb}).to_stderr

    expect(result.keys).to contain_exactly("AlsoValid", "Valid")
  end
end
