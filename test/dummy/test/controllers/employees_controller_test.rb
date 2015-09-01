require File.dirname(__FILE__) + '/../../../test_helper'

class EmployeesControllerTest < ActionController::TestCase
  setup do
    @employee  = Employee.create(name: 'Stephen', dob: Date.new(1963, 8, 13), joined: Date.new(2014, 4, 1))
    Employee.create(name: 'Tony', dob: Date.new(1965, 5, 17), joined: Date.new(2014, 5, 21))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create employee" do
    assert_difference('Employee.count') do
      post :create, employee: { dob: @employee.dob, joined: @employee.joined, name: @employee.name }
    end

    assert_redirected_to employee_path(assigns(:employee))
  end

  test "should show employee" do
    get :show, id: @employee
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @employee
    assert_response :success
  end

  test "should update employee" do
    patch :update, id: @employee, employee: { dob: @employee.dob, joined: @employee.joined, name: @employee.name }
    assert_redirected_to employee_path(assigns(:employee))
  end

  test "should destroy employee" do
    assert_difference('Employee.count', -1) do
      delete :destroy, id: @employee
    end

    assert_redirected_to employees_path
  end
end
