require 'byebug'
require 'minitest/autorun'
load 'lib/ny-addressor.rb'

class AddressesTest < MiniTest::Test
  def setup
    file = File.open("/home/cooperhanson/Documents/Projects/nearestyou/unprocessed_CSV_addresses.txt")
    addresses = file.read.split('"')
    @addresses = addresses.reject {|data| data.length() < 3}
    # @addresses = NYAddressor.new(addresses).output
  end

  def test_address0
    parts = NYAddressor.new(@addresses[0]).output
    assert parts[:street_number] == '4295'
    assert parts[:street_name] == 'jefferson davis'
    assert parts[:street_label] == 'hwy'
    assert parts[:city] == 'beech island'
    assert parts[:state] == 'sc'
    assert parts[:postal_code] == '29842'
  end

  def test_address1
    parts = NYAddressor.new(@addresses[1]).output
    assert parts[:street_number] == '4354'
    assert parts[:street_name] == '23rd'
    assert parts[:street_direction] == 'nw'
    assert parts[:street_label] == 'ave'
    assert parts[:city] == 'gainesville'
    assert parts[:state] == 'fl'
    assert parts[:postal_code] == '32606'
  end


end
