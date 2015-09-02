# GovUkDateFields
## Day/Month/Year input boxes for Rails projects

## Overview

The GOV.UK standard for date fields on web forms is to use three boxes - on each for day, month and year, rather 
than the drop_down boxes that comes as standard on rails projects.  This gem provides the methods required to 
easily display and validate dates entered into forms in this way.


## Getting Started

### 1. Add the Gem to your Gemfile

Add the following line to your Gemfile:

    gem 'gov_uk_date_fields'

Then run bundle install.


### 2. Tell your models attributes are gov_uk_dates

To specify date fields on the database that are to be rendered and validated as gov_uk_date_fields, 
simply add an acts_as_gov_uk_date to your model wth the attribute names of the date fields, e.g.:

  class Employee < ActiveRecord::Base
    acts_as_gov_uk_date :dob, :joined
  end

This tells the gem that there are two columns of type date on the database record for this model, ```dob``` and ```joined```, which will be rendered as three boxes on the form.


### 3. Update your form to render the three boxes

Add code like this to your form:

    <%= form_for(@employee) do |f| %>
      <div class="field">
        <%= f.label :dob %><br>
        <%= f.gov_uk_date_field :dob %>
      </div>

      <div class="field">
        <%= f.label :joined %><br>
        <%= f.gov_uk_date_field :joined %>
      </div>
    <% end %>


### 4. Permit the date parameters in your controller

Your controller needs to permit three parameters for each gov_uk_date field, so in the example above the 
employee_params method of the EmployeesController would be:

    def employee_params
      params.require(:employee).permit(:name, :dob_dd, :dob_mm, :dob_yyyy, :joined_dd, :joined_mm, :joined_yyyy)
    end

And you're ready to go.  

If the user enters values into the day/month/year boxes that can't be turned into a date, that field will be marked as 
invalid in the errors hash of the model during the validation cycle, and the entered values will be displayed back to
the user on the form.


## Licencing

This project rocks and uses MIT-LICENSE.

