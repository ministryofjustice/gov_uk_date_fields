require File.dirname(__FILE__) + '/../../../test_helper'


class EmployeeTest < ActiveSupport::TestCase
  
  def test_employee_class_responds_to_gov_uk_date_fields
    assert(Employee.respond_to?(:gov_uk_date_fields), 'Employee class does not respond to method :gov_uk_date_fields')
  end


end
