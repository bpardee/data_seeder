$:.push File.expand_path("../lib", __FILE__)

require "data_seeder/version"

Gem::Specification.new do |s|
  s.name        = "data_seeder"
  s.version     = DataSeeder::VERSION
  s.authors     = ["Brad Pardee"]
  s.email       = ["bradpardee@gmail.com"]
  s.homepage    = "http://github.com/bpardee/data_seeder"
  s.summary     = "Seed your Rails database"
  s.description = "Provides a simple methodology for seeding your Rails database"
  s.license     = "Apache License V2.0"

  s.files = Dir["{app,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_development_dependency "sqlite3"
end
