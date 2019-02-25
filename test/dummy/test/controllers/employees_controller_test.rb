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
      post :create, params: { employee: {
        dob_dd:       '31',
        dob_mm:       '12',
        dob_yyyy:     '1965',
        joined_dd:    '4',
        joined_mm:    'mar',
        joined_yyyy:  '2015',
        name:         'Joe Blow' }}
    end
    assert_redirected_to employee_path(assigns(:employee))
    assert_equal 3, Employee.count
    employee = Employee.last
    assert_equal 'Joe Blow', employee.name
    assert_equal Date.new(1965, 12, 31), employee.dob
    assert_equal Date.new(2015, 3, 4), employee.joined
  end

  test "should show employee" do
    get :show, params: { id: @employee }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: {id: @employee }
    assert_response :success
  end

  test "should update employee" do
    patch :update, params: {id: @employee, employee: {
      dob_dd:       '1',
      dob_mm:       '11',
      dob_yyyy:     '1981',
      joined_dd:    '3',
      joined_mm:    'oct',
      joined_yyyy:  '2015',
      name:         'Ioannis Kole' } }
    assert_redirected_to employee_path(assigns(:employee))
    e = Employee.find @employee.id
    assert_equal Date.new(1981, 11, 1), e.dob
    assert_equal Date.new(2015, 10, 3), e.joined
    assert_equal 'Ioannis Kole', e.name
  end

  test "should destroy employee" do
    assert_difference('Employee.count', -1) do
      delete :destroy, params: {id: @employee }
    end

    assert_redirected_to employees_path
  end

  test "should render gov_uk_date_fields" do
    get :edit, params: { id: @employee }

    assert_select 'input#employee_dob_dd' do
      assert_select '[type=?]','number'
      assert_select '[pattern=?]','[0-9]*'
    end
  end
end
