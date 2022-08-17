# Enable these lines to print a coverage report after the test suite completes.
# require 'simplecov'
# SimpleCov.start 'rails'

ENV["RAILS_ENV"] = 'test'

require_relative "../lib/fera/api"
require_relative "../lib/fera/app"

require 'bundler/setup'
require 'active_support/testing/time_helpers'
require "to_bool"

# Webmock allows us to mock responses from external requests by specifying a URL
# @see spec/factories/store_factory.rb for example usage
require 'webmock/rspec'
# By default WbeMock will disallow any http requests. Since we're doing lots of feature tests that need to do
# HTTP requests, we need to allow them all by default.
WebMock.allow_net_connect!
include WebMock::API # rubocop:disable Style/MixinUsage

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["support/**/*.rb"].sort.each { |f| require f }

# This is helpful for chaining `.and` although should be used sparingly to avoid confusion (see https://github.com/rspec/rspec-expectations/issues/493)
RSpec::Matchers.define_negated_matcher :not_change, :change

FIXTURES_DIRECTORY = File.join(File.dirname(__FILE__), 'fixtures')
def load_sample_json_file(file_name)
  str = File.read("#{ FIXTURES_DIRECTORY }/samples/#{ file_name.to_s.chomp('.json') }.json")
  JSON.parse(str)
end

RSpec.configure do |config|
  config.after(:each) do |example|
    next if !example.exception || $pryed_on_error

    if ENV['DEBUG'].to_bool || ENV['PRY_ON_ERROR'].to_bool
      puts Rainbow("[DEBUG MODE] Test failed:\n").red + example.exception.inspect
      binding.pry # rubocop:disable Lint/Debugger
    elsif ENV['ENABLE_SENTRY_FOR_TEST'].to_bool && ENV['HEROKU_TEST_RUN_BRANCH'] == 'master' && defined?(Raven)
      Raven.capture_exception(example.exception, extra: example.metadata.to_h.slice(:file_path, :line_number, :full_description))
    end
  end

  # Some useful helper methods that can be included in every spec
  config.include ActiveSupport::Testing::TimeHelpers # Rails time helpers

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end

  config.color = true
end
