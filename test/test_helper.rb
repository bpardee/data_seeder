ENV["RAILS_ENV"] ||= "test"
require_relative "dummy/config/environment"

# Needed for Dummy test app
require "minitest/autorun"
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
Rails.backtrace_cleaner.remove_silencers!
ActiveRecord::Migration.maintain_test_schema!

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
