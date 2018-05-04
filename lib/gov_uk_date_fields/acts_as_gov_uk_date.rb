module GovUkDateFields
  module ActsAsGovUkDate
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      VALID_ERROR_CLASH_BEHAVIOUR_OPTIONS = [
        :append_gov_uk_date_field_error,
        :omit_gov_uk_date_field_error,
        :override_with_gov_uk_date_field_error
      ]
      DEFAULT_GOV_UK_DATE_OPTIONS = {
        error_clash_behaviour: VALID_ERROR_CLASH_BEHAVIOUR_OPTIONS.first,
        validate_if: -> { true },
      }.freeze

      def acts_as_gov_uk_date(*date_fields)
        options = _extract_supported_options!(date_fields)

        validate :validate_gov_uk_dates, if: options[:validate_if]

        after_initialize :populate_gov_uk_dates

        cattr_accessor :_gov_uk_dates
        self._gov_uk_dates = date_fields


        # call valid? on each of the gov_uk date fields, and add error messages
        # into the errors hash if not valid
        #
        define_method(:validate_gov_uk_dates) do
          date_fields.each do |date_field|
            next if self.instance_variable_get("@_#{date_field}".to_sym).valid?
            case options[:error_clash_behaviour]
            when :append_gov_uk_date_field_error
              errors[date_field] << "Invalid date"
            when :omit_gov_uk_date_field_error
              next
            when :override_with_gov_uk_date_field_error
              errors[date_field].clear
              errors[date_field] << "Invalid date"
            end
          end
        end

        # For each of the gov uk date fields, we have to define the following 
        # instance methods (assuming the date field name is dob):
        #
        # * dob       - retuns the date object (i.e. @_dob.date)
        # * dob=      - populatees @_dob
        # * dob_dd    - returns the day value for form popualtion
        # * dob_dd=   - sets the day value (used when updating from a form)
        # * dob_mm    - returns the month value for form popualtion
        # * dob_mm=   - sets the month value (used when updating from a form)
        # * dob_yyyy  - returns the year value for form popualtion
        # * dob_yyyy= - sets the year value (used when updating from a form)
        #
        date_fields.each do |field|

          # #dob=(date) = assigns a date to the GovukDateFields::FormDate object
          define_method("#{field}=") do |new_date|
            raise ArgumentError.new("#{new_date} is not a Date object") unless new_date.respond_to?(:to_date) || new_date.nil?
            new_date = new_date.to_date unless new_date.nil?
            GovUkDateFields::FormDate.set_from_date(self, field, new_date)
            # if defined?(super)
              super(new_date)
            # else
            #   write_attribute(field, new_date)
            # end
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

        include GovUkDateFields::ActsAsGovUkDate::LocalInstanceMethods
      end

      protected

      def _supported_options
        [:error_clash_behaviour, :validate_if]
      end

      def _extract_supported_options!(args)
        options = DEFAULT_GOV_UK_DATE_OPTIONS.merge(args.extract_options!)
        options.assert_valid_keys(*_supported_options)
        raise ArgumentError.new("Invalid parameters specified for :error_clash_behaviour") unless options[:error_clash_behaviour].in?(VALID_ERROR_CLASH_BEHAVIOUR_OPTIONS)
        options
      end
    end

    module LocalInstanceMethods
      # This is an after initialize method.  We want to populate every gov_uk_date_field, unless it's a new
      # record, and there is already a non-nil form date (this happens when you call new and pass a hash of attributes and values)
      def populate_gov_uk_dates
        self._gov_uk_dates.each do |field_name|
          instance_variable_name = "@_#{field_name}"
          next if self.new_record? &&
                  self.instance_variable_defined?(instance_variable_name) &&
                  self.instance_variable_get(instance_variable_name) != nil
          GovUkDateFields::FormDate.set_from_date(self, field_name, self[field_name])
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, GovUkDateFields::ActsAsGovUkDate

