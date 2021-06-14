require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../../lib/gov_uk_date_fields/form_date.rb'


module GovUkDateFields
  class FormDateTest < ActiveSupport::TestCase


    def setup
      @employee = Employee.new(name: 'John', dob: Date.new(1963, 8, 13), joined: Date.new(2014, 4, 21))
    end


    def test_new_raises_error_if_called_from_outside_class
      err = assert_raise NoMethodError do
        fd = FormDate.new(2,3,2015)
      end
      assert_equal "private method `new' called for GovUkDateFields::FormDate:Class", err.message
    end

    def test_set_from_date_instantiates_the_attribute_and_is_valid
      FormDate.set_from_date(@employee, :joined, Date.new(2015, 4, 3))
      fd = @employee.instance_variable_get(:@_joined)
      assert_equal '3', fd.dd
      assert_equal '4', fd.mm
      assert_equal '2015', fd.yyyy
      assert_true fd.valid?, 'fd.valid?'
    end

    def test_set_from_date_instantiates_a_nil_object_if_date_is_nil
      FormDate.set_from_date(@employee, :joined, nil)
      fd = @employee.instance_variable_get(:@_joined)
      assert_equal '', fd.dd
      assert_equal '', fd.mm
      assert_equal '', fd.yyyy
      assert_true fd.valid?, 'fd.valid?'
    end

    def test_set_one_date_part_leaves_the_rest_unchanged
      fd = @employee.instance_variable_get(:@_dob)
      assert_equal Date.new(1963, 8, 13), fd.date
      FormDate.set_date_part(:dd, @employee, :dob, '5')
      assert_equal '5', fd.dd
      assert_equal fd.date, Date.new(1963, 8, 5)
    end

    def test_setting_all_three_date_parts_changes_the_date
      fd = @employee.instance_variable_get(:@_dob)
      assert_equal Date.new(1963, 8, 13), fd.date
      FormDate.set_date_part(:dd, @employee, :dob, '17')
      FormDate.set_date_part(:mm, @employee, :dob, '6')
      FormDate.set_date_part(:yyyy, @employee, :dob, '1965')
      assert_equal '17', fd.dd
      assert_equal '6', fd.mm
      assert_equal '1965', fd.yyyy
      assert_equal fd.date, Date.new(1965, 6, 17)
      assert_true fd.valid?, 'fd.valid?'
    end

    def test_setting_date_parts_with_invalid_values_marks_date_as_invalid_and_leaves_date_variable_the_same
      fd = @employee.instance_variable_get(:@_dob)
      assert_equal Date.new(1963, 8, 13), fd.date
      assert fd.valid?
      FormDate.set_date_part(:dd, @employee, :dob, '33')
      FormDate.set_date_part(:mm, @employee, :dob, 'abc')
      FormDate.set_date_part(:yyyy, @employee, :dob, '1965')
      assert_equal '33', fd.dd
      assert_equal 'abc', fd.mm
      assert_equal '1965', fd.yyyy
      assert_equal  Date.new(1963, 8, 13), fd.date
      assert_false fd.valid?, "fd.valid?"
    end

    def test_setting_all_date_parts_to_nil_sets_date_to_nil_and_is_valid
      fd = @employee.instance_variable_get(:@_dob)
      assert_equal Date.new(1963, 8, 13), fd.date
      assert fd.valid?
      FormDate.set_date_part(:dd, @employee, :dob, '')
      FormDate.set_date_part(:mm, @employee, :dob, '')
      FormDate.set_date_part(:yyyy, @employee, :dob, '')
      assert_equal '', fd.dd
      assert_equal '', fd.mm
      assert_equal '', fd.yyyy
      assert_nil fd.date
      assert_true fd.valid?, "fd.valid?"
    end



  end
end
