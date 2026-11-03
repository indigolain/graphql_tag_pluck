# frozen_string_literal: true

RSpec.describe "GraphqlTagPluck::VERSION" do
  it "is read from the VERSION file" do
    version_file = File.read(File.expand_path("../VERSION", __dir__)).strip

    expect(GraphqlTagPluck::VERSION).to eq(version_file)
  end

  it "is a valid gem version" do
    expect(Gem::Version.correct?(GraphqlTagPluck::VERSION)).to be(true)
  end
end
