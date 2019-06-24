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

  test 'date_fields_no_error' do
    fixture = file_fixture('date_fields_no_error.html').read

    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :dob)
    assert_html_equal(date_fields.raw_output, fixture)
  end

  test 'date_fields_error' do
    fixture = file_fixture('date_fields_error.html').read

    @employee.dob = nil
    @employee.errors.add(:dob, :blank)

    date_fields = GovUkDateFields::FormFields.new(@form_builder, :employee, :dob)
    assert_html_equal(date_fields.raw_output, fixture)
  end

  test 'date_fields_no_heading' do
    fixture = file_fixture('date_fields_no_heading.html').read

    date_fields = GovUkDateFields::FormFields.new(
      @form_builder, :employee, :dob,
      legend_options: { page_heading: false, visually_hidden: true }
    )
    assert_html_equal(date_fields.raw_output, fixture)
  end

  test 'date_fields with custom i18n_attribute' do
    date_fields = GovUkDateFields::FormFields.new(
      @form_builder, :employee, :dob, i18n_attribute: :custom_i18n_attribute
    )

    assert_match(
      /<h1 class="govuk-fieldset__heading">A custom legend<\/h1>/,
      date_fields.raw_output
    )

    assert_match(
      /<span class="govuk-hint" id="employee_dob_hint">A custom hint<\/span>/,
      date_fields.raw_output
    )
  end
end
