# frozen_string_literal: true

RSpec.describe GraphqlTagPluck, "interpolated heredocs" do
  it "skips heredocs with Ruby interpolation and warns with their location" do
    result = nil
    expect do
      result = pluck("a.rb" => <<~'RUBY')
        FIELDS = "id"
        A = <<~GRAPHQL
          query Interpolated { node { #{FIELDS} } }
        GRAPHQL
        B = <<~GRAPHQL
          query InstanceVar { node { #@fields } }
        GRAPHQL
        C = <<~GRAPHQL
          query Plain {
            node { id }
          }
        GRAPHQL
      RUBY
    end.to output(%r{interpolation at .*/a\.rb:2\n.*interpolation at .*/a\.rb:5\n}).to_stderr

    expect(result.keys).to eq(["Plain"])
  end

  it "keeps quoted heredocs, where #{} is literal text" do
    result = pluck("a.rb" => <<~'RUBY')
      A = <<~'GRAPHQL'
        query Quoted {
          node { id }
        }
      GRAPHQL
    RUBY

    expect(result.keys).to eq(["Quoted"])
  end
end
