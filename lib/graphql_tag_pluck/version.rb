# frozen_string_literal: true

module GraphqlTagPluck
  # The version lives in the plain-text VERSION file at the gem root, so a
  # release is a one-line change to that file (see .github/workflows/release.yml).
  VERSION = File.read(File.expand_path("../../VERSION", __dir__)).strip.freeze
end
