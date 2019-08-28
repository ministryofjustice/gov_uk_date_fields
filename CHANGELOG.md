# 4.1.0

* Markup will produce inputs with `type="text" inputmode="numeric"`.  
These are semantically correct and provides a better experience in most browsers, including mobile. More details in [this thread](https://github.com/alphagov/govuk-frontend/issues/1449#issuecomment-504006087)

This change **might** break your code if you target the input (in javascript, CSS or cucumber for example) by `type="number"`.

# 4.0.1

* Allow alternative i18n locales. [Read more details](https://github.com/ministryofjustice/gov_uk_date_fields/pull/36)

# 4.0.0

* **BREAKING CHANGE**: Support for new design system
* The gem will produce markup and style classes in line with the new [design system](https://design-system.service.gov.uk/components/date-input/)
* The gem will pick all the strings from i18n locales, and the ability to pass hardcoded strings has been removed
* There is no longer an option to show a 'today' button, and thus all related javascript has been removed
* Removed the stylesheet file, as all the styling is now coming from the design system

# Older versions

Please refer to the [releases page](https://github.com/ministryofjustice/gov_uk_date_fields/releases) and the [commits history](https://github.com/ministryofjustice/gov_uk_date_fields/commits/master).
