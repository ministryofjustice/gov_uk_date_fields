

ActionView::Helpers::FormBuilder.class_eval do

  def gov_uk_date_fieldxx(attribute)
    date_fields = GovUkDateFields::FormFields.new(self, @object_name, attribute)
    date_fields.output
  end

end

 