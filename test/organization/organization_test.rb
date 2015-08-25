# test/car/car_test.rb
require './test/test_helper'

class NewspilotOrganizationTest < Minitest::Test
  def test_exists
    assert Newspilot::Organization
  end

  def test_it_gives_back_a_single_organization
    VCR.use_cassette('Test') do
      organization = Newspilot::Organization.find(3)
      assert_equal Newspilot::Organization, organization.class

      # Check that the fields are accessible by our model
      assert_equal 3, organization.id
      assert_equal 'Organization name', organization.name
      assert_equal 'ON', organization.shortname
    end
  end
end
