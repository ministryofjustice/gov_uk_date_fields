class DefaultErrorClashEmployee < Employee

  acts_as_gov_uk_date :dob, :joined

  validates :dob, presence: true
  validates :joined, presence: true

end
