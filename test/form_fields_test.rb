require  File.dirname(File.expand_path(__FILE__)) + '/test_helper'

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

  def expected_fieldset_output_with_id
    %Q{
      <fieldset id="employee_date_joined">
        <legend>Joining date</legend>
        <div class="form-date">
          <p class="form-hint" id="joined-hint">For example, 31 3 1980</p>
          <div class="form-group form-group-day">
            <label for="joined-day">Day</label>
            <input class="form-control" id="joined-day" name="joined-day" type="number" pattern="[0-9]*" min="0" max="31" aria-describedby="joined-hint" value="1">
          </div>
          <div class="form-group form-group-month">
            <label for="joined-month">Month</label>
            <input class="form-control" id="joined-month" name="joined-month" type="number" pattern="[0-9]*" min="0" max="12" value="4">
          </div>
          <div class="form-group form-group-year">
            <label for="joined-year">Year</label>
            <input class="form-control" id="joined-year" name="joined-year" type="number" pattern="[0-9]*" min="0" max="2016" value="2015">
          </div>
        </div>
      </fieldset>
    }
  end

  def expected_fieldset_output_with_form_hint
    %Q{
      <fieldset>
        <legend class="govuk_legend_class">Date of birth</legend>
        <div class="form-date">
          <p class="form-hint" id="dob-hint">In the form: dd mm yyyy</p>
          <div class="form-group form-group-day">
            <label for="dob-day">Day</label>
            <input class="form-control" id="dob-day" name="dob-day" type="number" pattern="[0-9]*" min="0" max="31" aria-describedby="dob-hint" value="7">
          </div>
          <div class="form-group form-group-month">
            <label for="dob-month">Month</label>
            <input class="form-control" id="dob-month" name="dob-month" type="number" pattern="[0-9]*" min="0" max="12" value="12">
          </div>
          <div class="form-group form-group-year">
            <label for="dob-year">Year</label>
            <input class="form-control" id="dob-year" name="dob-year" type="number" pattern="[0-9]*" min="0" max="2016" value="1963">
          </div>
        </div>
      </fieldset>
    }
  end

  def expected_fieldset_output_with_legend_class
    %Q{
      <fieldset>
        <legend class="date-legend-class">Joining date</legend>
        <div class="form-date">
          <p class="form-hint" id="joined-hint">For example, 31 3 1980</p>
          <div class="form-group form-group-day">
            <label for="joined-day">Day</label>
            <input class="form-control" id="joined-day" name="joined-day" type="number" pattern="[0-9]*" min="0" max="31" aria-describedby="joined-hint" value="1">
          </div>
          <div class="form-group form-group-month">
            <label for="joined-month">Month</label>
            <input class="form-control" id="joined-month" name="joined-month" type="number" pattern="[0-9]*" min="0" max="12" value="4">
          </div>
          <div class="form-group form-group-year">
            <label for="joined-year">Year</label>
            <input class="form-control" id="joined-year" name="joined-year" type="number" pattern="[0-9]*" min="0" max="#{Date.today.year}" value="2015">
          </div>
        </div>
      </fieldset>
    }
  end


end
