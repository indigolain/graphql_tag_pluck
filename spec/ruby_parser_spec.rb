# frozen_string_literal: true

RSpec.describe GraphqlTagPluck::RubyParser do
  it "uses Prism's parser translation on Ruby 3.3+ and the parser gem before that" do
    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3")
      expect(described_class).to equal(Prism::Translation::ParserCurrent)
    else
      expect(described_class).to equal(Parser::CurrentRuby)
    end
  end

  it "plucks heredocs from files using syntax the parser gem rejects" do
    skip "needs Ruby 4.0+ syntax" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("4.0")

    # A leading && continuing the previous line is Ruby 4.0 syntax; the
    # parser gem raises "unexpected token tAMPER" on it.
    result = pluck("modern.rb" => <<~RUBY)
      ok = true
        && false
      Q = <<~GRAPHQL
        query Modern { a }
      GRAPHQL
    RUBY

    expect(result.keys).to eq(["Modern"])
  end
end
