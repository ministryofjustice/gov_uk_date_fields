class MyValidator < ActiveModel::Validator
  def validate(record)
    [:dob, :joined].each do |date_field|
      if record.__send__(date_field).nil?
        record.errors[date_field] << "Can't be blank"
      end
    end
  end
end




class OverrideErrorClashEmployee < Employee

  validates_with MyValidator

  acts_as_gov_uk_date :dob, :joined, error_clash_behaviour: :override_with_gov_uk_date_field_error



end

