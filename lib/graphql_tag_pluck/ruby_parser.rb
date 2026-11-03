# frozen_string_literal: true

require "parser"

module GraphqlTagPluck
  # The parser gem only understands Ruby syntax up to 3.3 and warns on every
  # load under newer Rubies. From Ruby 3.3 on, use Prism's translation layer,
  # which produces the same Parser::AST nodes but follows the running Ruby's
  # syntax. Older Rubies keep using the parser gem, which supports them.
  RubyParser =
    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3")
      require "prism"
      Prism::Translation::ParserCurrent
    else
      require "parser/current"
      ::Parser::CurrentRuby
    end
end
