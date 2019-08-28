module GovUkDateFields
  class FormFields
    include ActionView::Context
    include ActionView::Helpers::TagHelper

    delegate :concat, to: :@output_buffer

    DATE_SEGMENTS = {
      day:    '_dd',
      month:  '_mm',
      year:   '_yyyy',
    }.freeze

    def initialize(form, object_name, attribute, options={})
      @form               = form
      @object             = form.object
      @object_name        = object_name
      @attribute          = attribute
      @options            = options
      @day_value          = @object.send("#{@attribute}_dd")&.gsub(/\D/, '')
      @month_value        = @object.send("#{@attribute}_mm")&.gsub(/\D/, '')
      @year_value         = @object.send("#{@attribute}_yyyy")&.gsub(/\D/, '')
    end

    def raw_output
      generate_input_fields
    end

    def output
      raw_output.html_safe
    end

    private

    def generate_input_fields
      content_tag(:div, class: form_group_classes) do
        content_tag(:fieldset, fieldset_options(@attribute, @options)) do
          concat fieldset_legend(@attribute, @options)
          concat hint(@attribute)
          concat error(@attribute)
          concat input_fields_div
        end
      end
    end

    def generate_input_for(name, value, width: 2)
      css_class = "govuk-input govuk-date-input__input govuk-input--width-#{width}"
      css_class += " govuk-input--error" if error_for_attr?

      content_tag(:div, class: 'govuk-date-input__item') do
        content_tag(:div, class: 'govuk-form-group') do
          %Q|
            <label class="govuk-label govuk-date-input__label" for="#{html_id(name)}">#{localized_label(name)}</label>
            <input class="#{css_class}" id="#{html_id(name)}" name="#{html_name(name)}" value="#{value}" type="text" inputmode="numeric" pattern="[0-9]*">
          |.html_safe
        end
      end
    end

    def error_for_attr?
      @object.errors.keys.include?(@attribute) && @object.errors[@attribute].any?
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
      [attribute_prefix, @attribute].join('_')
    end

    def form_group_hint_id
      [form_group_id, 'hint'].join('_')
    end

    def form_group_classes
      classes = ['govuk-form-group']
      classes << 'govuk-form-group--error' if error_for_attr?
      classes
    end

    def fieldset_options(attribute, options)
      defaults = { class: 'govuk-fieldset', role: 'group' }

      aria_ids = []
      aria_ids << id_for(attribute, 'hint')  if hint(attribute)
      aria_ids << id_for(attribute, 'error') if error_for_attr?

      # If the array is empty, `#presence` will return nil
      defaults['aria-describedby'] = aria_ids.presence

      merge_attributes(
        options[:fieldset_options],
        default: defaults
      )
    end

    def fieldset_legend(attribute, options)
      default_attrs = { class: 'govuk-fieldset__legend' }.freeze
      default_opts  = { visually_hidden: false, page_heading: true, size: 'xl' }.freeze

      legend_options = merge_attributes(
        options[:legend_options],
        default: default_attrs
      ).reverse_merge(
        default_opts
      )

      opts = legend_options.extract!(*default_opts.keys)

      legend_options[:class] << " govuk-fieldset__legend--#{opts[:size]}"
      legend_options[:class] << " govuk-visually-hidden" if opts[:visually_hidden]

      # The `page_heading` option can be false to disable "Legends as page headings"
      # https://design-system.service.gov.uk/get-started/labels-legends-headings/
      #
      if opts[:page_heading]
        content_tag(:legend, legend_options) do
          content_tag(:h1, fieldset_text(attribute), class: 'govuk-fieldset__heading')
        end
      else
        content_tag(:legend, fieldset_text(attribute), legend_options)
      end
    end

    def input_fields_div
      content_tag(:div, class: 'govuk-date-input', id: form_group_id) do
        concat generate_input_for(:day, @day_value)
        concat generate_input_for(:month, @month_value)
        concat generate_input_for(:year, @year_value, width: 4)
      end
    end

    def hint(attribute)
      return unless hint_text(attribute)
      content_tag(:span, hint_text(attribute), class: 'govuk-hint', id: id_for(attribute, 'hint'))
    end

    def error(attribute)
      return unless error_for_attr?

      text = error_full_message_for(attribute)
      content_tag(:span, text, class: 'govuk-error-message', id: id_for(attribute, 'error'))
    end

    def id_for(attribute, suffix)
      [attribute_prefix, attribute, suffix].join('_')
    end

    def default_label attribute
      attribute.to_s.split('.').last.humanize.capitalize
    end

    def fieldset_text attribute
      localized 'helpers.fieldset', attribute, default_label(attribute)
    end

    def hint_text attribute
      localized 'helpers.hint', attribute, ''
    end

    def localized_label attribute
      localized 'helpers.label', attribute, default_label(attribute)
    end

    def error_full_message_for attribute
      message = @object.errors.full_messages_for(attribute).first
      message&.sub default_label(attribute), localized_label(attribute)
    end

    # If a form view is reused but the attribute doesn't change (for example in
    # partials) an `i18n_attribute` can be used to lookup the legend or hint locales
    # based on this, instead of the original attribute.
    #
    # We prioritise the `i18n_attribute` if provided, and if no locale is found,
    # we try the 'real' attribute as a fallback and finally the default value.
    #
    def localized scope, attribute, default
      found = if @options[:i18n_attribute]
        key = "#{@object_name}.#{@options[:i18n_attribute]}"

        I18n.translate(key, default: '', scope: scope).presence ||
          I18n.translate("#{key}_html", default: '', scope: scope).html_safe.presence
      end

      return found if found

      key = "#{@object_name}.#{attribute}"

      # Passes blank String as default because nil is interpreted as no default
      I18n.translate(key, default: '', scope: scope).presence ||
        I18n.translate("#{key}_html", default: default, scope: scope).html_safe.presence
    end

    # Given an attributes hash that could include any number of arbitrary keys, this method
    # ensure we merge one or more 'default' attributes into the hash, creating the keys if
    # don't exist, or merging the defaults if the keys already exists.
    # It supports strings or arrays as values.
    #
    def merge_attributes attributes, default:
      hash = attributes || {}
      hash.merge(default) { |_key, oldval, newval| Array(newval) + Array(oldval) }
    end
  end
end
