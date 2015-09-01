module GovUkDateFields
  module ActsAsGovUkDate
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_gov_uk_date(*date_fields)
        cattr_accessor :_gov_uk_dates
        self._gov_uk_dates = date_fields

        # For each of the gov uk date fields, we have to define the following 
        # instance methods (assuming the date field name is dob):
        #
        # * dob       - retuns the date object (i.e. @_dob.date)
        # * dob=      - populatees @_dob
        # * dob_dd    - returns the day value for form popualtion
        # * dob_mm    - returns the month value for form popualtion
        # * dob_yyyy  - returns the year value for form popualtion
        #
        date_fields.each do |field|

          # #dob -return @_dob.date
          define_method(field) do
            return self.instance_variable_get("@_#{field}".to_sym).date
          end

          # #dob=(date) = assigns a date to the GovukDateFields::FormDate object
          define_method("#{field}=") do |new_date|
            raise ArgumentError.new("#{new_date} is not a Date object") unless new_date.is_a?(Date)
            GovUkDateFields::FormDate.set_from_date(self, field, new_date)
          end

          # #dob_dd   - return the day value for form population
          define_method("#{field}_dd") do
            return self.instance_variable_get("@_#{field}".to_sym).dd
          end       

          # #dob_mm   - return the day value for form population
          define_method("#{field}_mm") do
            return self.instance_variable_get("@_#{field}".to_sym).mm
          end    

          # #dob_yyyy   - return the day value for form population
          define_method("#{field}_yyyy") do
            return self.instance_variable_get("@_#{field}".to_sym).yyyy
          end  

          # #dob_dd= - set the day part of the date (used in population of model from form)
          define_method("#{field}_dd=") do |day| 
            GovUkDateFields::FormDate.set_date_part(:dd, self, field, day)
          end   

          # #dob_dd= - set the day part of the date (used in population of model from form)
          define_method("#{field}_mm=") do |month| 
            GovUkDateFields::FormDate.set_date_part(:mm, self, field, month)
          end   

          # #dob_dd= - set the day part of the date (used in population of model from form)
          define_method("#{field}_yyyy=") do |year| 
            GovUkDateFields::FormDate.set_date_part(:yyyy, self, field, year)
          end   

        end

        after_initialize :populate_gov_uk_dates

        include GovUkDateFields::ActsAsGovUkDate::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def populate_gov_uk_dates
        self._gov_uk_dates.each do |field_name|
          GovUkDateFields::FormDate.set_from_date(self, field_name, self[field_name])
        end
      end

      # def populate_gov_uk_dates_from_form_fields
      #   MojDateFields::FormDate.set_from_date(self, :first_day_of_trial, self['first_day_of_trial'])
      # end
    end


  end
end

ActiveRecord::Base.send :include, GovUkDateFields::ActsAsGovUkDate

