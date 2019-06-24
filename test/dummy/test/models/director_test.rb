require 'pp'
require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../../lib/gov_uk_date_fields/gov_uk_date_fields'


class DirectorTest < ActiveSupport::TestCase

  def setup
    @director = Director.new(name: 'John', dob: Date.new(1963, 8, 13), joined: Date.new(2014, 4, 21))
  end

  def test_director_class_responds_to_acts_as_gov_uk_date
    assert(Director.respond_to?(:acts_as_gov_uk_date), 'Director class does not respond to method :gov_uk_date_fields')
  end

  def test_director_has_class_variable_describing_all_gov_uk_dates
    assert_equal([:dob, :joined], Director._gov_uk_dates)
  end

  def test_valid_dates_raise_no_errors_when_validation_disabled
    assert_true @director.valid?, '@director.valid?'
  end

  def test_nil_dates_raise_no_errors_when_validation_disabled
    @director.dob = nil
    assert_true @director.valid?, '@director.valid?'
  end

  def test_invalid_day_raises_no_error_when_validation_disabled
    @director.dob_dd = '32'
    assert_true @director.valid?
    assert_equal [], @director.errors[:dob]
  end

  def test_creating_a_new_director_with_invalid_dates_is_valid_when_validation_disabled
    e = Director.new(name: 'Stephen', dob_dd: '13', dob_mm: 'XXX', dob_yyyy: '1963')
    assert_nil e.dob
    assert_true e.valid?
  end

  def test_updating_existing_record_with_invalid_dates_is_valid_when_validation_disabled
    @director.save!
    assert_equal Date.new(1963, 8, 13), @director.dob
    @director.update(dob_dd: '47', dob_mm: '5', dob_yyyy: '1965')
    assert_equal Date.new(1963, 8, 13), @director.dob
    assert_true @director.valid?
  end
end
