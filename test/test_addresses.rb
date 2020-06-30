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

  def test_address2
    parts = NYAddressor.new(@addresses[2]).output
    assert parts[:street_number] == '2040' #155
    assert parts[:street_name] == 'western'
    assert parts[:street_label] == 'ave'
    assert parts[:city] == 'guilderland' #route western guilderland
    assert parts[:state] == 'ny'
    assert parts[:postal_code] == '12203'
  end

  def test_address3
    parts = NYAddressor.new(@addresses[3]).output
    assert parts[:street_name] == 'faith'
    assert parts[:street_label] == 'plz'
    assert parts[:city] == 'ravena'
    assert parts[:state] == 'ny'
    assert parts[:postal_code] == '12143'
  end

  def test_address4
    parts = NYAddressor.new(@addresses[4]).output
    assert parts[:street_number] == '1475'
    assert parts[:street_name] == 'western'
    assert parts[:street_label] == 'ave'
    assert parts[:city] == 'albany'
    assert parts[:state] == 'ny'
    assert parts[:postal_code] == '12203'
  end

  def test_address5
    parts = NYAddressor.new(@addresses[5]).output
    assert parts[:street_number] == '70'
    assert parts[:street_name] == 'steuben'
    assert parts[:street_label] == 'st'
    assert parts[:street_direction] == 'w'
    assert parts[:city] == 'crafton'
    assert parts[:state] == 'pa'
    assert parts[:postal_code] == '15205'
  end

  def test_address6
    parts = NYAddressor.new(@addresses[6]).output
    assert parts[:street_number] == '10170'
    assert parts[:street_name] == 'illinois'
    assert parts[:street_label] == 'rd'
    assert parts[:city] == 'fort wayne'
    assert parts[:state] == 'in'
    assert parts[:postal_code] == '46814'
  end

  def test_address13
    parts = NYAddressor.new(@addresses[13]).output
    assert parts[:unit] == 'room 2b1080'
    assert parts[:city] == 'arlington'
    assert parts[:state] == 'va'
    assert parts[:postal_code] == '22202'
  end


end
