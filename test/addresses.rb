require 'minitest/autorun'
require 'byebug'
load 'lib/ny-addressor.rb'

class AddressesTest < MiniTest::Test
  def test_4933_yukon
    nya = NYAddressor.new('4933 Yukon AVE N, New Hope, MN 55428')
    assert nya.parts == {street_number: '4933', street_name: 'Yukon', street_label: 'AVE', street_direction: 'N', city: 'New Hope', state: 'MN', postal_code: '55428'}
  end

  def test_white_house
    nya = NYAddressor.new('1600 Pennsylvania Ave NE, Washington, DC 20202')
    assert nya.parts == {
      street_number: '1600',
      street_name: 'Pennsylvania',
      street_label: 'Ave',
      street_direction: 'NE',
      city: 'Washington',
      state: 'DC',
      postal_code: '20202'
    }
  end

  def test_multi_city_state
    nya = NYAddressor.new('5301 Radford Rd, Water Town, South Dakota, USA')
    assert nya.parts == {
      street_number: '5301',
      street_name: 'Radford',
      street_label: 'Rd',
      city: 'Water Town',
      state: 'South Dakota',
      country: 'USA'
    }
  end

  def test_rr_po_box
    nya = NYAddressor.new('R.r. #4 Box 82, Keyser, WV 26726')
    assert nya.parts == {
      street_name: 'R.r. #4',
      street_number: 'Box 82',
      city: 'Keyser',
      state: 'WV',
      postal_code: '26726'
    }
  end

  def test_generic_po_box
    nya = NYAddressor.new('PO Box 1033 Los Angeles CA')
    assert nya.parts == {
      street_name: 'PO Box',
      street_number: '1033',
      city: 'Los Angeles',
      state: 'CA'
    }
  end

end
