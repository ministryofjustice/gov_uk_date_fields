class OmitErrorClashEmployee < Employee

  acts_as_gov_uk_date :dob, :joined, error_clash_behaviour: :omit_gov_uk_date_field_error

  validates :dob, presence: true
  validates :joined, presence: true

end
