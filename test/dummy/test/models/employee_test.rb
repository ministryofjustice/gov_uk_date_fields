require 'pp'
require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../../lib/gov_uk_date_fields/gov_uk_date_fields'


class EmployeeTest < ActiveSupport::TestCase


  def setup
    @employee = Employee.new(name: 'John', dob: Date.new(1963, 8, 13), joined: Date.new(2014, 4, 21))
  end
  
  def test_employee_class_responds_to_acts_as_gov_uk_date
    assert(Employee.respond_to?(:acts_as_gov_uk_date), 'Employee class does not respond to method :gov_uk_date_fields')
  end

  def test_employee_has_class_variable_describing_all_gov_uk_dates
    assert_equal( [ :dob, :joined], Employee._gov_uk_dates)
  end

  def test_employee_instance_has_form_date_instance_variables_for_each_gov_uk_date
    assert @employee.instance_variable_get(:@_dob).is_a?(GovUkDateFields::FormDate)
    assert_equal Date.new(1963, 8, 13), @employee.instance_variable_get(:@_dob).date
    assert_equal '13', @employee.instance_variable_get(:@_dob).dd
    assert_equal '8', @employee.instance_variable_get(:@_dob).mm
    assert_equal '1963', @employee.instance_variable_get(:@_dob).yyyy

    assert @employee.instance_variable_get(:@_joined).is_a?(GovUkDateFields::FormDate)
    assert_equal Date.new(2014, 4, 21), @employee.instance_variable_get(:@_joined).date
    assert_equal '21', @employee.instance_variable_get(:@_joined).dd
    assert_equal '4', @employee.instance_variable_get(:@_joined).mm
    assert_equal '2014', @employee.instance_variable_get(:@_joined).yyyy    
  end

  def test_that_the_calling_the_field_name_on_employee_will_return_the_date_part_of_the_form_date_object
    assert_equal Date.new(1963, 8, 13), @employee.dob
  end


  def test_that_we_can_assign_new_dates_to_the_form_date_object
    @employee.dob = Date.new(2014, 12, 25)
    assert_equal Date.new(2014, 12, 25), @employee.instance_variable_get(:@_dob).date
    assert_equal '25', @employee.instance_variable_get(:@_dob).dd
    assert_equal '12', @employee.instance_variable_get(:@_dob).mm
    assert_equal '2014', @employee.instance_variable_get(:@_dob).yyyy

    @employee.joined = Date.new(2015, 12, 31)
    assert_equal Date.new(2015, 12, 31), @employee.instance_variable_get(:@_joined).date
    assert_equal '31', @employee.instance_variable_get(:@_joined).dd
    assert_equal '12', @employee.instance_variable_get(:@_joined).mm
    assert_equal '2015', @employee.instance_variable_get(:@_joined).yyyy
  end

  def test_that_nil_can_be_assigned_to_a_date_field
    @employee.dob = nil
    assert_equal nil, @employee.dob
    assert_equal '', @employee.dob_dd
    assert_equal '', @employee.dob_mm
    assert_equal '', @employee.dob_yyyy
  end

  def test_that_argument_error_is_raised_if_unparseable_string_object_is_assigned_to_a_date_field
    err = assert_raise ArgumentError do
      @employee.dob = 'Some string'
    end
    assert err.is_a?(ArgumentError)
    assert_equal 'invalid date', err.message
  end

  def test_no_argument_error_is_raised_if_parseable_string_is_assigned_to_a_date_field
    @employee.dob = '13/8/1963'
    assert Date.new(1963, 8, 13), @employee.dob
  end

  def test_argument_error_is_raised_if_an_object_that_doesnt_respond_to_to_date_is_assigned_to_a_date_field
    err = assert_raise ArgumentError do
      @employee.dob = [13, 8, 1963]
    end
    assert err.is_a?(ArgumentError)
    assert_equal "[13, 8, 1963] is not a Date object", err.message
  end

  def test_that_form_population_values_can_be_extracted_from_the_date_field
    assert_equal '21', @employee.joined_dd
    assert_equal '4', @employee.joined_mm
    assert_equal '2014', @employee.joined_yyyy
  end


  def test_new_dates_can_be_populated_from_the_form
    @employee.dob_dd = '17'
    @employee.dob_mm = 'jun'
    @employee.dob_yyyy = '1965'
    assert_equal Date.new(1965, 6, 17), @employee.dob 
  end


  def test_valid_dates_raise_no_errors
    assert_true @employee.valid?, '@employee.valid?'
  end

  def test_nil_dates_raise_no_errors
    @employee.dob = nil
    assert_true @employee.valid?, '@employee.valid?'
  end

  def test_invalid_day_raises_error
    @employee.dob_dd = '32'
    assert_false @employee.valid?
    assert_equal ['Invalid date'], @employee.errors[:dob]
  end

  def test_createing_a_new_employee_with_valid_dates_is_valid
    e = Employee.new(name: 'Stephen', dob_dd: '13', dob_mm: 'AUG', dob_yyyy: '1963')
    assert_equal Date.new(1963, 8, 13), e.dob
    assert_true e.valid?
  end

  def test_creating_a_new_employee_with_invalid_dates_is_invalid
    e = Employee.new(name: 'Stephen', dob_dd: '13', dob_mm: 'XXX', dob_yyyy: '1963')
    assert_equal nil, e.dob
    assert_false e.valid?
  end

  def test_updating_existing_record_with_valid_dates_is_valid
    @employee.save!
    @employee.update(dob_dd: '17', dob_mm: '5', dob_yyyy: '1965')
    assert_equal Date.new(1965, 5, 17), @employee.dob
    assert_true @employee.valid?
  end

  def test_updating_existing_record_with_invalid_dates_is_invalid
    @employee.save!
    @employee.update(dob_dd: '47', dob_mm: '5', dob_yyyy: '1965')
    assert_equal Date.new(1963, 8, 13), @employee.dob
    assert_false @employee.valid?
  end  

end
