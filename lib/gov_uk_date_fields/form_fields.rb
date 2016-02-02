module GovUkDateFields

  class FormFields
    DATE_SEGMENTS = {
      day:    '_dd',
      month:  '_mm',
      year:   '_yyyy'
    }

    DEFAULT_PLACEHOLDERS = {
      day: 'DD',
      month: 'MM',
      year: 'YYYY'
    }

    def initialize(form, object_name, attribute, options={})
      @form        = form
      @object      = form.object
      @object_name = object_name
      @attribute   = attribute
      @options = options
    end

    def output
      day_value = @object.send("#{@attribute}_dd")
      month_value = @object.send("#{@attribute}_mm")
      year_value = @object.send("#{@attribute}_yyyy")

      %Q[
        #{@form.text_field(@attribute, field_options(day_value, html_id(:day), html_name(:day), placeholder(:day), 2))}
        #{@form.text_field(@attribute, field_options(month_value, html_id(:month), html_name(:month), placeholder(:month), 3))}
        #{@form.text_field(@attribute, field_options(year_value, html_id(:year), html_name(:year), placeholder(:year), 4))}
      ].html_safe
    end

    private

    def placeholder(part)
      if @options[:placeholders] == true
        DEFAULT_PLACEHOLDERS[part]
      else
        @options[:placeholders][part] || DEFAULT_PLACEHOLDERS[part] if @options[:placeholders]
      end
    end

    def html_id(date_segment)
      html_name(date_segment).gsub(/\]\[|\[|\]|\(/, '_').gsub(/\_\z/, '').gsub(/\)/, '')
    end

    def html_name(date_segment)
      "#{@object_name}[#{@attribute}#{DATE_SEGMENTS[date_segment]}]"
    end

    def field_options(value, id, name, placeholder, size)
      {
        value: value,
        id: id,
        name: name,
        placeholder: placeholder,
        size: size
      }
    end
  end
end