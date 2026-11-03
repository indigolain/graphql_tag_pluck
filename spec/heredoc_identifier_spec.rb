# frozen_string_literal: true

RSpec.describe GraphqlTagPluck, "heredoc identifier matching" do
  it "plucks heredocs whose identifier is configured, in every heredoc form" do
    result = pluck("a.rb" => <<~'RUBY')
      A = <<GRAPHQL
      query Plain { a }
      GRAPHQL
      B = <<-GQL
        query Dash { b }
      GQL
      C = <<~'GRAPHQL'
        query SingleQuoted { c }
      GRAPHQL
      D = <<~"GRAPHQL"
        query DoubleQuoted { d }
      GRAPHQL
    RUBY

    expect(result.keys).to contain_exactly("Plain", "Dash", "SingleQuoted", "DoubleQuoted")
  end

  it "ignores heredocs whose identifier only contains a configured identifier" do
    result = pluck("a.rb" => <<~RUBY)
      A = <<~NOT_GRAPHQL_DOC
        just text, not graphql
      NOT_GRAPHQL_DOC
      B = <<~GQL_EXAMPLE
        more text
      GQL_EXAMPLE
    RUBY

    expect(result).to eq({})
  end

  it "matches custom identifiers exactly" do
    source = <<~RUBY
      A = <<~QL
        query Custom { a }
      QL
      B = <<~GRAPHQL
        query Default { b }
      GRAPHQL
    RUBY

    expect(pluck({ "a.rb" => source }, graphql_heredoc_identifiers: ["QL"]).keys).to eq(["Custom"])
  end
end
