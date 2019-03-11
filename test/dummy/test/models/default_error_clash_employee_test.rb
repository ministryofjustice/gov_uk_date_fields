require 'pp'
require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../../lib/gov_uk_date_fields/gov_uk_date_fields'


class DefaultErrorClashEmployeeTest < ActiveSupport::TestCase


  def setup
    @employee = DefaultErrorClashEmployee.new(name: 'John', dob: nil, joined: nil)
  end

  def test_presence_error_messages_generated
    @employee.valid?
    assert_equal ["Enter the date of birth"], @employee.errors[:dob]
    assert_equal ["can't be blank"], @employee.errors[:joined]
  end

  def test_invalid_day_adds_invalid_date_message_to_cant_be_blank_message
    @employee.dob_dd = '32'
    assert_false @employee.valid?
    assert_equal ['Invalid date', "Enter the date of birth"], @employee.errors[:dob]
    assert_equal ["can't be blank"], @employee.errors[:joined]
  end

  def test_valid_dates_generate_no_errors_at_all
    @employee.dob_dd = '15'
    @employee.dob_mm = '8'
    @employee.dob_yyyy = '2016'
    assert_empty @employee.errors[:dob]
  end
end

