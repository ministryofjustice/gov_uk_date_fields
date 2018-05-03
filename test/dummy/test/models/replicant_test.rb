require 'pp'
require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../../../../lib/gov_uk_date_fields/gov_uk_date_fields'


class ReplicantTest < ActiveSupport::TestCase
  test 'joined date is same as dob' do
    @roy = Replicant.new(name: 'Roy', dob: Date.new(2016, 1, 8))
    assert_equal(@roy.dob, @roy.joined)
  end
end
