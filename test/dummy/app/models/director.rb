class Director < Employee

  acts_as_gov_uk_date :dob, :joined, validate_if: :perform_validation?

  def perform_validation?
    false
  end

end
