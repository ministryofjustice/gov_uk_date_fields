$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gov_uk_date_fields/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gov_uk_date_fields"
  s.version     = GovUkDateFields::VERSION
  s.authors     = ["Stephen Richards"]
  s.email       = ["stephen.richards@digital.justice.gov.uk"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of GovUkDateFields."
  s.description = "TODO: Description of GovUkDateFields."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "pg"
end
