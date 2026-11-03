# frozen_string_literal: true

RSpec.describe GraphqlTagPluck, "duplicate operation names" do
  def query_file(body)
    <<~RUBY
      Q = <<~GRAPHQL
        #{body}
      GRAPHQL
    RUBY
  end

  it "warns when a different definition reuses an operation name" do
    expect do
      pluck("a.rb" => query_file("query Dup { a }"), "b.rb" => query_file("query Dup { b }"))
    end.to output(%r{Dup in .*\.rb overwrites a different definition with the same name in .*\.rb}).to_stderr
  end

  it "does not warn when the same definition appears twice" do
    expect do
      result = pluck("a.rb" => query_file("query Same { a }"), "b.rb" => query_file("query Same { a }"))
      expect(result.keys).to eq(["Same"])
    end.not_to output.to_stderr
  end
end
