source "https://rubygems.org"

# Declare your gem's dependencies in data_seeder.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
group :test, :development do
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-plus', :git => 'git://github.com/avantcredit/pry-plus'
  gem 'pry-rails'
end

group :test do
  gem 'minitest-rails'
end
