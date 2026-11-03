# frozen_string_literal: true

RSpec.describe GraphqlTagPluck, "duplicate operation names" do
  def query_file(body)
    <<~RUBY
      Q = <<~GRAPHQL
        #{body}
      GRAPHQL
    RUBY
  end

  it "raises when a different definition reuses an operation name, naming both locations" do
    expect do
      pluck_from_project_root("a.rb" => query_file("query Dup { a }"), "b.rb" => query_file("query Dup { b }"))
    end.to raise_error(
      GraphqlTagPluck::Error,
      "Duplicate GraphQL definition name `Dup`: defined at a.rb:2 and b.rb:2"
    )
  end

  it "raises even when the same definition appears twice" do
    expect do
      pluck_from_project_root("a.rb" => query_file("query Same { a }"), "b.rb" => query_file("query Same { a }"))
    end.to raise_error(GraphqlTagPluck::Error, /Duplicate GraphQL definition name `Same`/)
  end

  it "raises for duplicate fragment names too" do
    expect do
      pluck("a.rb" => query_file("fragment F on User { id }"), "b.rb" => query_file("fragment F on User { name }"))
    end.to raise_error(GraphqlTagPluck::Error, /`F`/)
  end
end
