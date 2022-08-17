# frozen_string_literal: true

require_relative "lib/fera/api/version"

Gem::Specification.new do |spec|
  spec.name = "fera-api"
  spec.version = Fera::API::VERSION
  spec.authors = ["Fera Commerce Inc"]
  spec.email = ["developers@fera.ai"]

  spec.summary = "Fera API gem"
  spec.description = "Fera API SDK gem to make it easy to interact with the Fera API to gather and display customer review, photos and videos."
  spec.homepage = "https://developers.fera.ai"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activemodel", ">= 4"
  spec.add_dependency "activeresource", ">= 6"
  spec.add_dependency "activesupport", ">= 4.0"
  spec.add_dependency "json-jwt", ">= 1"
  spec.add_dependency "require_all", ">= 2"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "to_bool"
  spec.add_development_dependency "webmock", ">= 3.0"
end
