$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "data_seeder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "data_seeder"
  s.version     = DataSeeder::VERSION
  s.authors     = ["Brad Pardee"]
  s.email       = ["bradpardee@gmail.com"]
  s.homepage    = "http://github.com/bpardee/data_seeder"
  s.summary     = "TODO: Summary of DataSeeder."
  s.description = "TODO: Description of DataSeeder."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_development_dependency "sqlite3"
end
