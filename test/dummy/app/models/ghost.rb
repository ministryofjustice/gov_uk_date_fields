class Ghost
  extend ActiveRecord::Attributes::ClassMethods

  attribute :dod, :date

  acts_as_gov_uk_date :dod
end
