require 'pp'
require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../../lib/gov_uk_date_fields/gov_uk_date_fields'


class GhostTest < ActiveSupport::TestCase
  test 'setting attribute using write_attribute' do
    @casper = Ghost.new
    @casper.dod = Date.today
    assert_equal(@casper.dod, Date.today)
  end
end
