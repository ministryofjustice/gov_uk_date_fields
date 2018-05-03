class Replicant < Employee
  def self.synchronise_dates(*date_fields)
    setters = Module.new do
      date_fields.each do |date_field|
        define_method("#{date_field}=") do |value|
          super(value)
          (date_fields - [date_field]).each do |other_date_field|
            write_attribute(other_date_field, value)
          end
        end
      end
    end
    include setters
  end

  synchronise_dates   :dob, :joined
  acts_as_gov_uk_date :dob, :joined

end
