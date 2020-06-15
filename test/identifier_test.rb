require 'minitest/autorun'
load 'lib/identifier.rb'
require 'byebug'

class NYAddressorTest < MiniTest::Test
  def test_clean_string
    nyi = NYIdentifier.new
    nyi.str = '1600 Pennsylvania Ave (at 39th st), Washington, DC (West coast), 20202'
    nyi.clean_string
    assert nyi.str = '1600 Pennsylvania Ave Washington DC 20202'
    assert nyi.bus[:parentheses].sort == ['at 39th st', 'West coast'].sort
  end

  def test_identify_all_by_pattern
    nyi = NYIdentifier.new
    nyi.str = '4933 Yukon Ave N New Hope MN 55428'
    nyi.clean_string
    nyi.separate
    assert nyi.sep == ['4933', 'Yukon', 'Ave', 'N', 'New', 'Hope', 'MN', '55428']
    nyi.create_sep_map
    nyi.identify_all_by_pattern
    assert nyi.sep_map.select{|data| data[:text] == '4933'}.first[:from_pattern] == [:street_number, :street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Yukon'}.first[:from_pattern] == [:street_name, :city, :state, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'Ave'}.first[:from_pattern] == [:street_label, :city, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'N'}.first[:from_pattern] == [:street_direction, :city, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'New'}.first[:from_pattern] == [:city, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'Hope'}.first[:from_pattern] == [:city, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'MN'}.first[:from_pattern] == [:city, :state, :country]
    assert nyi.sep_map.select{|data| data[:text] == '55428'}.first[:from_pattern] == [:street_number, :postal_code]
  end

  def test_identify_all_by_location
    nyi = NYIdentifier.new
    nyi.str = '4933 Yukon Ave N New Hope MN 55428'
    nyi.clean_string
    nyi.separate
    nyi.create_sep_map
    nyi.identify_all_by_location
    assert nyi.sep_map.select{|data| data[:text] == '4933'}.first[:from_location] == [:street_number, :street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Yukon'}.first[:from_location] == [:street_number, :street_name, :street_direction]
    assert nyi.sep_map.select{|data| data[:text] == 'Ave'}.first[:from_location] == [:street_name, :street_label, :street_unit]
    assert nyi.sep_map.select{|data| data[:text] == 'N'}.first[:from_location] == [:street_name, :street_label, :street_direction, :unit, :city, :state]
    assert nyi.sep_map.select{|data| data[:text] == 'New'}.first[:from_location] == [:street_name, :street_label, :street_direction, :unit, :city, :state]
    assert nyi.sep_map.select{|data| data[:text] == 'Hope'}.first[:from_location] == [:city, :state]
    assert nyi.sep_map.select{|data| data[:text] == 'MN'}.first[:from_location] == [:state, :postal_code]
    assert nyi.sep_map.select{|data| data[:text] == '55428'}.first[:from_location] == [:postal_code, :country]
  end

  def test_consolidate_identity_options
    nyi = NYIdentifier.new
    nyi.str = '4933 Yukon Ave N New Hope MN 55428'
    nyi.clean_string
    nyi.separate
    nyi.create_sep_map
    nyi.identify_all_by_pattern
    nyi.identify_all_by_location
    nyi.consolidate_identity_options
    assert nyi.sep_map.select{|data| data[:text] == '4933'}.first[:in_both] == [:street_number, :street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Yukon'}.first[:in_both] == [:street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Ave'}.first[:in_both] == [:street_label]
    assert nyi.sep_map.select{|data| data[:text] == 'N'}.first[:in_both] == [:street_direction, :city]
    assert nyi.sep_map.select{|data| data[:text] == 'New'}.first[:in_both] == [:city]
    assert nyi.sep_map.select{|data| data[:text] == 'Hope'}.first[:in_both] == [:city]
    assert nyi.sep_map.select{|data| data[:text] == 'MN'}.first[:in_both] == [:state]
    assert nyi.sep_map.select{|data| data[:text] == '55428'}.first[:in_both] == [:postal_code]
  end
end
