module GovUkDateFields

  class FormFields
    VALID_OPTIONS = [:legend_text, :legend_class, :form_hint_text, :id, :placeholders, :error_messages, :today_button]

    DATE_SEGMENTS = {
      day:    '_dd',
      month:  '_mm',
      year:   '_yyyy',
    }

    DEFAULT_PLACEHOLDERS = {
      day: 'DD',
      month: 'MM',
      year: 'YYYY'
    }

    def initialize(form, object_name, attribute, options={})
      @form               = form
      @object             = form.object
      @object_name        = object_name
      @attribute          = attribute
      @options            = options
      @day_value          = @object.send("#{@attribute}_dd")&.gsub(/\D/, '')
      @month_value        = @object.send("#{@attribute}_mm")&.gsub(/\D/, '')
      @year_value         = @object.send("#{@attribute}_yyyy")&.gsub(/\D/, '')
      @form_hint_text     = @options[:form_hint_text] || "For example, 31 3 1980"
      @fieldset_required  = false
      @fieldset_id        = @options[:id]
      @error_messages     = @options[:error_messages]
      @hint_id            = form_group_hint_id
      @today_button       = @options[:today_button] || false
      parse_options
    end

    def raw_output
      if fieldset_required?
        generate_input_fields
      else
        generate_old_style_input_fields
      end
    end

    def output
      raw_output.html_safe
    end

  private

    def error_for_attr?
      error_attribute_names.include?(@attribute) && @object.errors[@attribute].any?
    end

    def error_attribute_names
      if @object.errors.respond_to?(:attribute_names)
        @object.errors.attribute_names
      else
        @object.errors.keys
      end
    end

    def fieldset_required?
      @fieldset_required
    end

    def generate_old_style_input_fields
      %Q[
        #{@form.text_field(@attribute, field_options(@day_value, html_id(:day), html_name(:day), placeholder(:day), 2))}
        #{@form.text_field(@attribute, field_options(@month_value, html_id(:month), html_name(:month), placeholder(:month), 3))}
        #{@form.text_field(@attribute, field_options(@year_value, html_id(:year), html_name(:year), placeholder(:year), 4))}
      ]
    end

    def generate_start_fieldset
      %Q|
        #{generate_fieldset_tag}
          #{generate_legend_tag}
            <span class="form-label-bold">#{@options[:legend_text]}</span>
            <span class="form-hint" id="#{@hint_id}">#{@form_hint_text}</span>
            #{generate_error_message}
          </legend>
          <div class="form-date">
      |
    end

    def generate_fieldset_tag
      css_class = "form-group gov_uk_date"
      css_class += " form-group-error" if error_for_attr?

      result = %Q|
                <div class="#{css_class}"|
      result += %Q| id="#{form_group_id}"|
      result += ">"
      result += %Q| <fieldset|
      result += ">"
      result
    end

    def generate_end_fieldset
      "</div></fieldset></div>"
    end

    def generate_legend_tag
      if @options.key?(:legend_class)
        %Q|<legend class="#{@options[:legend_class]}">|
      else
        "<legend>"
      end
    end

    def generate_error_message
      result = ''
      if error_for_attr?
        result = "<ul>"
        if @error_messages.nil?
          @error_messages = @object.errors[@attribute]
        end
        @error_messages.each do |message|
          result += %Q|<li><span class="error-message">#{message}</span></li>|
        end
        result += "</ul>"
      end
      result
    end

    def generate_input_fields
      result = generate_start_fieldset
      result += generate_today_button if @today_button
      result += generate_day_input_field(@day_value) + generate_month_input_field(@month_value) + generate_year_input_field(@year_value)
      result += generate_end_fieldset
      result
    end

    def today_button_class
      if @today_button.is_a?(Hash) && @today_button.key?(:class)
        @today_button[:class]
      else
        'button'
      end
    end

    def generate_today_button
      %Q|<a class="#{today_button_class}" role="button" href="#">Today</a>|
    end

    def generate_start_div
      %Q|<div class="form-group form-group-day">|
    end

    def generate_end_div
      %Q|</div>|
    end

    def generate_day_input_field(day_value)
      css_class = "form-control"
      css_class += " form-control-error" if error_for_attr?

      result = %Q|
          <div class="form-group form-group-day">
            <label for="#{html_id(:day)}">Day</label>
            <input class="#{css_class}" id="#{html_id(:day)}" name="#{html_name(:day)}" type="number" min="0" max="31" aria-describedby="#{@hint_id}" value="#{day_value}">
          </div>
      |
    end

    def generate_month_input_field(month_value)
      css_class = "form-control"
      css_class += " form-control-error" if error_for_attr?

      result = %Q|
        <div class="form-group form-group-month">
          <label for="#{html_id(:month)}">Month</label>
          <input class="#{css_class}" id="#{html_id(:month)}" name="#{html_name(:month)}" type="number" min="0" max="12" value="#{month_value}">
        </div>
      |
    end

    def generate_year_input_field(year_value)
      css_class = "form-control"
      css_class += " form-control-error" if error_for_attr?

      result = %Q|
        <div class="form-group form-group-year">
          <label for="#{html_id(:year)}">Year</label>
          <input class="#{css_class}" id="#{html_id(:year)}" name="#{html_name(:year)}" type="number" min="0" max="2100" value="#{year_value}">
        </div>
      |
    end

    def parse_options
      validate_option_keys
      if @options.key?(:legend_text) || @options.key?(:id)
        @fieldset_required = true
      else
        if @options.key?(:legend_class) || @options.key?(:form_hint_text)
          raise ArgumentError.new("Invalid combination of options: You must specifigy :legend_text if :legend_class or :form_hint_text are specified")
        end
      end
    end

    def validate_option_keys
      @options.keys.each do |option_key|
        unless VALID_OPTIONS.include?(option_key)
          raise ArgumentError.new("Invalid option key: #{option_key.inspect}")
        end
      end
    end


    def placeholder(part)
      if @options[:placeholders] == true
        DEFAULT_PLACEHOLDERS[part]
      else
        @options[:placeholders][part] || DEFAULT_PLACEHOLDERS[part] if @options[:placeholders]
      end
    end

    def html_id(date_segment)
      brackets2underscore(html_name(date_segment))
    end

    def html_name(date_segment)
      "#{@object_name}[#{@attribute}#{DATE_SEGMENTS[date_segment]}]"
    end

    def brackets2underscore(string)
      string.tr('[','_').tr(']', '_').gsub('__', '_').gsub(/_$/, '')
    end

    def attribute_prefix
      brackets2underscore(@object_name.to_s)
    end

    def form_group_id
      # If an `id` option was passed, this takes precedence, to ensure backward compatibility
      return @fieldset_id if @fieldset_id

      group_id = [attribute_prefix, @attribute]
      group_id.unshift('error') if error_for_attr?
      group_id.join('_')
    end

    def form_group_hint_id
      # If an `id` option was passed, this takes precedence, to ensure backward compatibility
      return "#{@fieldset_id}-hint" if @fieldset_id

      [attribute_prefix, @attribute].join('_') + '-hint'
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
