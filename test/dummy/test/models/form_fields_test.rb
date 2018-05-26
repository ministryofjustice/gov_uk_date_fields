require 'mocha/test_unit'

require  File.dirname(File.expand_path(__FILE__)) + '/../../../test_helper'

class MockTemplate
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  attr_accessor :output_buffer

  def surround(start_html, end_html, &block)
    "#{start_html}#{block.call}#{end_html}"
  end
end

class GovUkDateFieldsTest < ActiveSupport::TestCase

  def setup
    @employee = Employee.new(dob: Date.new(1963, 12, 7), joined: Date.new(2015, 4, 1))
    @template = MockTemplate.new
    @form_builder = ActionView::Helpers::FormBuilder.new(:employee, @employee, @template, {} )
  end


  test "error raised if invalid options given" do
    err = assert_raise do
      GovUkDateFields::FormFields.new(@form_builder, :employee, :dob, rubbish: 'some_value')
    end
  end


  test "basic_output_without_fieldset" do
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :dob)
    assert_html_equal(date_fields.raw_output, expected_basic_output_without_fieldset)
  end

  test 'placeholder_output_without_fieldset' do
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :dob, {placeholders: { day: 'DAY', month: 'MTH', year: 'YEAR' } })
    assert_html_equal(date_fields.raw_output, expected_placeholder_output_without_fieldset)
  end

  test 'fieldset_output_with_form_hint' do
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :dob, {legend_text: 'Date of birth', legend_class: 'govuk_legend_class', form_hint_text: 'In the form: dd mm yyyy'})
    assert_html_equal(date_fields.raw_output, expected_fieldset_output_with_form_hint)
  end

  test 'fieldset output with legend class' do
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :joined, {legend_text: 'Joining date', legend_class: 'date-legend-class', form_hint_text: 'For example, 31 3 1980'})
    assert_html_equal(date_fields.raw_output, expected_fieldset_output_with_legend_class)
  end

  test 'fieldset with id' do
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :joined, {legend_text: 'Joining date', id: 'employee_date_joined'})
    assert_html_equal(date_fields.raw_output, expected_fieldset_output_with_id)
  end

  test 'fieldset output with today button with no css class specified' do
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :joined, {legend_text: 'Joining date', id: 'employee_date_joined', today_button: true})
    assert_html_equal(date_fields.raw_output, expected_fieldset_output_with_unstyled_today_button)
  end

  test 'fieldset output with today button with css class applied' do
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :joined, {legend_text: 'Joining date', id: 'employee_date_joined', today_button: {class: 'today-button-class'} } )
    assert_html_equal(date_fields.raw_output, expected_fieldset_output_with_syled_today_button)
  end

  test 'fieldset with error_class and message' do
    @employee.errors[:joined] <<  "Invalid joining date"
    @employee.errors[:joined] <<  "Joining date must be in the past"
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :joined, {legend_text: 'Joining date', id: 'employee_date_joined'})
    assert_html_equal(date_fields.raw_output, expected_fieldset_output_with_error_class_and_message)
  end

  test 'fieldset with error_class and supplied error messages' do
    @employee.errors[:joined] <<  "invalid"
    @employee.errors[:joined] <<  "must_be_in_past"
    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :joined, {legend_text: 'Joining date', id: 'employee_date_joined', error_messages: ['Invalid joining date', 'Joining date must be in the past']})
    assert_html_equal(date_fields.raw_output, expected_fieldset_output_with_error_class_and_message)
  end

  test "squash_html" do
    html = "   <html>  This is some   text \n  <tr>  \n    <td>  <%=   dfkhdfh   %>  </td>  </tr>\n</html> "
    expected_result = "<html>This is some   text<tr><td><%=   dfkhdfh   %></td></tr></html>"
    assert_html_equal(html, expected_result)
  end


  def expected_basic_output_without_fieldset
    %Q{
      <input value="7" id="employee_dob_dd" name="employee[dob_dd]" size="2" type="text" />
      <input value="12" id="employee_dob_mm" name="employee[dob_mm]" size="3" type="text" />
      <input value="1963" id="employee_dob_yyyy" name="employee[dob_yyyy]" size="4" type="text" />
    }
  end


  def expected_placeholder_output_without_fieldset
    %Q{
      <input value="7" id="employee_dob_dd" name="employee[dob_dd]" placeholder="DAY" size="2" type="text" />
      <input value="12" id="employee_dob_mm" name="employee[dob_mm]" placeholder="MTH" size="3" type="text" />
      <input value="1963" id="employee_dob_yyyy" name="employee[dob_yyyy]" placeholder="YEAR" size="4" type="text" />
    }
  end

  def expected_fieldset_output_with_error_class_and_message
    %Q{
      <div class="form-group gov_uk_date form-group-error" id="employee_date_joined">
        <fieldset>
          <legend>
            <span class="form-label-bold">Joining date</span>
            <span class="form-hint" id="employee_date_joined-hint">
              For example, 31 3 1980
            </span>
            <ul>
              <li><span class="error-message">Invalid joining date</span></li>
              <li><span class="error-message">Joining date must be in the past</span></li>
            </ul>
          </legend>
          <div class="form-date">
            <div class="form-group form-group-day">
              <label for="employee_joined_dd">Day</label>
              <input class="form-control form-control-error" id="employee_joined_dd" name="employee[joined_dd]" type="number" pattern="\\d*" min="0" max="31" aria-describedby="employee_date_joined-hint" value="1">
            </div>
            <div class="form-group form-group-month">
              <label for="employee_joined_mm">Month</label>
              <input class="form-control form-control-error" id="employee_joined_mm" name="employee[joined_mm]" type="number" pattern="\\d*" min="0" max="12" value="4">
            </div>
            <div class="form-group form-group-year">
              <label for="employee_joined_yyyy">Year</label>
              <input class="form-control form-control-error" id="employee_joined_yyyy" name="employee[joined_yyyy]" type="number" pattern="\\d*" min="0" max="2100" value="2015">
            </div>
          </div>
        </fieldset>
      </div>
    }
  end

  def expected_fieldset_output_with_id
    %Q{
      <div class="form-group gov_uk_date" id="employee_date_joined">
        <fieldset>
          <legend>
            <span class="form-label-bold">Joining date</span>
            <span class="form-hint" id="employee_date_joined-hint">For example, 31 3 1980</span>
          </legend>
          <div class="form-date">
            <div class="form-group form-group-day">
              <label for="employee_joined_dd">Day</label>
              <input class="form-control" id="employee_joined_dd" name="employee[joined_dd]" type="number" pattern="\\d*" min="0" max="31" aria-describedby="employee_date_joined-hint" value="1">
            </div>
            <div class="form-group form-group-month">
              <label for="employee_joined_mm">Month</label>
              <input class="form-control" id="employee_joined_mm" name="employee[joined_mm]" type="number" pattern="\\d*" min="0" max="12" value="4">
            </div>
            <div class="form-group form-group-year">
              <label for="employee_joined_yyyy">Year</label>
              <input class="form-control" id="employee_joined_yyyy" name="employee[joined_yyyy]" type="number" pattern="\\d*" min="0" max="2100" value="2015">
            </div>
          </div>
        </fieldset>
      </div>
    }
  end

  def expected_fieldset_output_with_form_hint
    %Q{
      <div class="form-group gov_uk_date">
        <fieldset>
          <legend class="govuk_legend_class">
            <span class="form-label-bold">Date of birth</span>
            <span class="form-hint" id="dob-hint">In the form: dd mm yyyy</span>
          </legend>
          <div class="form-date">
            <div class="form-group form-group-day">
              <label for="employee_dob_dd">Day</label>
              <input class="form-control" id="employee_dob_dd" name="employee[dob_dd]" type="number" pattern="\\d*" min="0" max="31" aria-describedby="dob-hint" value="7">
            </div>
            <div class="form-group form-group-month">
              <label for="employee_dob_mm">Month</label>
              <input class="form-control" id="employee_dob_mm" name="employee[dob_mm]" type="number" pattern="\\d*" min="0" max="12" value="12">
            </div>
            <div class="form-group form-group-year">
              <label for="employee_dob_yyyy">Year</label>
              <input class="form-control" id="employee_dob_yyyy" name="employee[dob_yyyy]" type="number" pattern="\\d*" min="0" max="2100" value="1963">
            </div>
          </div>
        </fieldset>
      </div>
    }
  end

  def expected_fieldset_output_with_legend_class
    %Q{
      <div class="form-group gov_uk_date">
        <fieldset>
          <legend class="date-legend-class">
            <span class="form-label-bold">Joining date</span>
            <span class="form-hint" id="joined-hint">For example, 31 3 1980</span>
          </legend>
          <div class="form-date">
            <div class="form-group form-group-day">
              <label for="employee_joined_dd">Day</label>
              <input class="form-control" id="employee_joined_dd" name="employee[joined_dd]" type="number" pattern="\\d*" min="0" max="31" aria-describedby="joined-hint" value="1">
            </div>
            <div class="form-group form-group-month">
              <label for="employee_joined_mm">Month</label>
              <input class="form-control" id="employee_joined_mm" name="employee[joined_mm]" type="number" pattern="\\d*" min="0" max="12" value="4">
            </div>
            <div class="form-group form-group-year">
              <label for="employee_joined_yyyy">Year</label>
              <input class="form-control" id="employee_joined_yyyy" name="employee[joined_yyyy]" type="number" pattern="\\d*" min="0" max="2100" value="2015">
            </div>
          </div>
        </fieldset>
      </div>
    }
  end

  def expected_fieldset_output_with_unstyled_today_button
    %Q{
      <div class="form-group gov_uk_date" id="employee_date_joined">
        <fieldset>
          <legend>
            <span class="form-label-bold">Joining date</span>
            <span class="form-hint" id="employee_date_joined-hint">For example, 31 3 1980</span>
          </legend>
          <div class="form-date">
            <a class="button" role="button" href="#">Today</a>
            <div class="form-group form-group-day">
                <label for="employee_joined_dd">Day</label>
                <input class="form-control" id="employee_joined_dd" name="employee[joined_dd]" type="number" pattern="\\d*" min="0" max="31" aria-describedby="employee_date_joined-hint" value="1">
            </div>
            <div class="form-group form-group-month">
                <label for="employee_joined_mm">Month</label>
                <input class="form-control" id="employee_joined_mm" name="employee[joined_mm]" type="number" pattern="\\d*" min="0" max="12" value="4">
            </div>
            <div class="form-group form-group-year">
                <label for="employee_joined_yyyy">Year</label>
                <input class="form-control" id="employee_joined_yyyy" name="employee[joined_yyyy]" type="number" pattern="\\d*" min="0" max="2100" value="2015">
            </div>
          </div>
        </fieldset>
      </div>
    }
  end

  def expected_fieldset_output_with_syled_today_button
    %Q{
      <div class="form-group gov_uk_date" id="employee_date_joined">
        <fieldset>
          <legend>
            <span class="form-label-bold">Joining date</span>
            <span class="form-hint" id="employee_date_joined-hint">For example, 31 3 1980</span>
          </legend>
          <div class="form-date">
            <a class="today-button-class" role="button" href="#">Today</a>
            <div class="form-group form-group-day">
                <label for="employee_joined_dd">Day</label>
                <input class="form-control" id="employee_joined_dd" name="employee[joined_dd]" type="number" pattern="\\d*" min="0" max="31" aria-describedby="employee_date_joined-hint" value="1">
            </div>
            <div class="form-group form-group-month">
                <label for="employee_joined_mm">Month</label>
                <input class="form-control" id="employee_joined_mm" name="employee[joined_mm]" type="number" pattern="\\d*" min="0" max="12" value="4">
            </div>
            <div class="form-group form-group-year">
                <label for="employee_joined_yyyy">Year</label>
                <input class="form-control" id="employee_joined_yyyy" name="employee[joined_yyyy]" type="number" pattern="\\d*" min="0" max="2100" value="2015">
            </div>
          </div>
        </fieldset>
      </div>
    }
  end

end
