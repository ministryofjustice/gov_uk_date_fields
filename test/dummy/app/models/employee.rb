class Employee < ActiveRecord::Base

  acts_as_gov_uk_date :dob, :joined

end

