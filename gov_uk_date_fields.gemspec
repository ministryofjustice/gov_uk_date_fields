$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gov_uk_date_fields/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gov_uk_date_fields"
  s.version     = GovUkDateFields::VERSION
  s.date        = GovUkDateFields::VERSION_RELEASED
  s.authors     = ["Stephen Richards","Joel Sugarman"]
  s.email       = ["stephen.richards@digital.justice.gov.uk","joel.sugarman@digital.justice.gov.uk"]
  s.homepage    = "https://github.com/ministryofjustice/gov_uk_date_fields"
  s.summary     = "Enable day-month-year text edit fields for form date entry"
  s.description = "Provides acts_as_gov_uk_date to mark Rails model attributes " +
                  "as dates that will be entered as three separate text edit boxes, " +
                  "and a form_builder method gov_uk_date_field to display those fields."
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.require_paths = ["lib"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '>= 5.0.7.2'
end
