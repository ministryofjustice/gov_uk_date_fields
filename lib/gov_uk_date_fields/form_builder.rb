

ActionView::Helpers::FormBuilder.class_eval do

  def gov_uk_date_field(attribute, options={})
    date_fields = GovUkDateFields::FormFields.new(self, @object_name, attribute, options)
    date_fields.output
  end

end

 