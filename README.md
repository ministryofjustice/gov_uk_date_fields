# GovUkDateFields
## Day/Month/Year input boxes for Rails projects

## Overview

The GOV.UK standard for date fields on web forms is to use three boxes - one each for day, month and year, rather 
than the drop_down boxes that comes as standard on rails projects.  This gem provides the methods required to 
easily display and validate dates entered into forms in this way.


## Getting Started

Follow the four simple steps below.  In the example below, we assume there is an Employee model with 
attributes, ```name```, ```dob```, ```joined```, the last two attributes being ```gov_uk_dates```.  Note 
that these must be defined on the database as ```date``` fields, not ```datetime```.

### 1. Add the Gem to your Gemfile

Add the following line to your Gemfile:

    gem 'gov_uk_date_fields', '~> 1.0.0'

Then run bundle install.


### 2. Tell your models attributes are gov_uk_dates

To specify date fields on the database that are to be rendered and validated as gov_uk_date_fields, 
simply add an acts_as_gov_uk_date to your model wth the attribute names of the date fields, e.g.:

    class Employee < ActiveRecord::Base
      acts_as_gov_uk_date :dob, :joined
    end

This tells the gem that there are two columns of type date on the database record for this model, ```dob``` and ```joined```, which will be rendered as three boxes on the form.

You can also specify a Proc or a Symbol pointing to a method that checks whether the date validations should be performed. This is optional and by default validations are always performed. Example:

    acts_as_gov_uk_date :dob, :joined, validate_if: :perform_validation?

### 3. Permit the date parameters in your controller

Your controller needs to permit three parameters for each gov_uk_date field, so in the example above the 
employee_params method of the EmployeesController would be:

    def employee_params
      params.require(:employee).permit(:name, :dob_dd, :dob_mm, :dob_yyyy, :joined_dd, :joined_mm, :joined_yyyy)
    end


### 4. Update your form to render the three boxes

Use the gov_uk_date_field method that this gem adds into FormBuilder to create the three
date field boxes in the form:

    <%= form_for(@employee) do |f| %>
       <%= f.gov_uk_date_field :dob, legend_text: 'Date of birth' %>
   
       <%= f.gov_uk_date_field :joined, legend_text: 'Date joined' %>
    <% end %>

#### 4.1. Options passed to gov_uk_date_field

The FormBuilder method gov_uk_date_field takes two parameters:
  
  * the method on the model that the FormBuilder is encapsulating
  
  * an option hash desribing how the date fields should be rendered:
  
    - **an empty hash or nil**: means the date fields will be rendered as per version 0.1.0 of this gem, 
      that is just three input fields with no encapsulating fieldset, divs, or legends.  This is 
      now deprecated and should no longer be used, but is included for backward 
      compatibility with versions 0.0.1 and 0.0.2.
      
    - **placeholder**: see below for an explanation of how to specify placeholders.  This is now deprecated 
      and should no longer be used, but is included for backward compatibility with versions 0.0.1 and 0.0.2.
      
    - **legend_text**: The text that is to be used as the title of the Date field set.
    
    - **legend_class**: The CSS class that is to be used for the legend
    
    - **form_hint_text**: The text that is to advise the user how to fill in the form.  If not specified, 
      the text "For example, 31 3 1980" will be used.
      
    - **id**: The id to be given to the fieldset.  If absent, no id will be assigned to the fieldset.  This setting also affects the id of the hint element:
      if specified, then the hint element will have the fieldset id appended by '-hint', otherwise it will have the attribute name appeneded by '-hint'.  The hint-id is
      referred to by the aria-described-by attribute on the input element.

    - **error_messages**: Error messages to be attached to the field, if not the string in the errors collection of the object.
      This is useful if the error messages are held in a translation file for example - the client should fetch the translations and
      pass in as an array of strings as the value for this option.



##### 4.1.1 Placeholders:

  Supply your own

    <%= f.gov_uk_date_field :dob, placeholders: { day: 'dd', month: 'mm', year: 'yyyy' } %>

  or enable defaults (DD/MM/YYYY)

    <%= f.gov_uk_date_field :dob, placeholders: true %>

### 5.  You're done!

You're ready to go.

If the user enters values into the day/month/year boxes that can't be turned into a date, the attribute will be marked as 
invalid in the model's errors hash during the validation cycle, and the entered values will be displayed back to
the user on the form.


## FAQs

### What is the HTML that this gem produces?

Given an employee object with the dob attribute set to
  
    Date.new(1965, 7, 13)
  
the following call to the gov_uk_date_field method:

    f.gov_uk_date_field(:dob, legend_text: 'Date of birth', legend_class: 'govuk-legend')
    
will produce the following HTML:

      <fieldset>
        <legend class="govuk_legend">Date of birth</legend>
        <div class="form-date">
          <p class="form-hint" id="dob-hint">For example, 31 3 1980</p>
          <div class="form-group form-group-day">
            <label for="dob-day">Day</label>
            <input class="form-control" 
                   id="dob-day" 
                   name="dob-day" 
                   type="number" 
                   pattern="[0-9]*" 
                   min="0"
                   max="31" 
                   aria-describedby="dob-hint" 
                   value="13">
          </div>
          <div class="form-group form-group-month">
            <label for="dob-month">Month</label>
            <input class="form-control" 
                   id="dob-month" 
                   name="dob-month" 
                   type="number" 
                   pattern="[0-9]*" 
                   min="0" 
                   max="12" 
                   value="7">
          </div>
          <div class="form-group form-group-year">
            <label for="dob-year">Year</label>
            <input class="form-control" 
                   id="dob-year" 
                   name="dob-year" 
                   type="number" 
                   pattern="[0-9]*" 
                   min="0" 
                   max="2016" 
                   value="1965">
          </div>
        </div>
      </fieldset>



See other examples in the file `test/form_fields_test.rb
`
## Licencing

This project rocks and uses MIT-LICENSE.

