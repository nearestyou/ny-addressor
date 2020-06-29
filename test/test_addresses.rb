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

  
end
