# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"
require "minitest/reporters"
require 'rails-controller-testing'

Rails::Controller::Testing.install

# configure minitest reporting
reporter_options = { color: true }
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new(reporter_options)

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new


# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.fixtures :all
end



def assert_false(actual_value, message = nil)
  assert_equal false, actual_value, "#{message} was expected to be false, is #{actual_value}"
end


def assert_true(actual_value, message = nil)
  assert_equal true, actual_value, "#{message} was expected to be true, is #{actual_value}"
end


def assert_html_equal(actual_html, expected_html)
  assert_equal(squash_html(actual_html), squash_html(expected_html), "\nExpected: #{squash_html(expected_html)}\nGot:      #{squash_html(actual_html)}")
end

def squash_html(html)
  html.gsub("\n", "").gsub(/\s*</, "<").gsub(/>\s*/, ">")
end



