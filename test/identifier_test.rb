require 'minitest/autorun'
load 'lib/identifier.rb'
require 'byebug'

###
# 1600 Pennsylvania Ave NE, Washington, DC 20202
# 4933 Yukon Ave N New Hope MN 55428
# R.r. #4 Box 82, Keyser, WV 26726
# 5301 Radford Rd, Watertown, South Dakota, USA
###

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
    nyi.str = '1600 Pennsylvania Ave NE, Washington, DC 20202'
    nyi.clean_string
    nyi.separate
    assert nyi.sep == ['1600', 'Pennsylvania', 'Ave', 'NE', 'Washington', 'DC', '20202']
    nyi.create_sep_map
    nyi.identify_all_by_pattern
    assert nyi.sep_map.select{|data| data[:text] == '1600'}.first[:from_pattern] == [:street_number, :street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Pennsylvania'}.first[:from_pattern] == [:street_name, :city, :state, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'Ave'}.first[:from_pattern] == [:street_name, :street_label, :city, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'NE'}.first[:from_pattern] == [:street_name, :street_direction, :city, :state, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'Washington'}.first[:from_pattern] == [:street_name, :city, :state, :country]
    assert nyi.sep_map.select{|data| data[:text] == 'DC'}.first[:from_pattern] == [:street_name, :city, :state, :country]
    assert nyi.sep_map.select{|data| data[:text] == '20202'}.first[:from_pattern] == [:street_number, :street_name, :postal_code]
  end

  def test_identify_all_by_location
    nyi = NYIdentifier.new
    nyi.str = '1600 Pennsylvania Ave NE, Washington, DC 20202'
    nyi.clean_string
    nyi.separate
    nyi.create_sep_map
    nyi.identify_all_by_location
    assert nyi.sep_map.select{|data| data[:text] == '1600'}.first[:from_location] == [:street_number, :street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Pennsylvania'}.first[:from_location] == [:street_number, :street_name, :street_direction]
    assert nyi.sep_map.select{|data| data[:text] == 'Ave'}.first[:from_location] == [:street_name, :street_label, :street_unit]
    assert nyi.sep_map.select{|data| data[:text] == 'NE'}.first[:from_location] == [:street_name, :street_label, :street_direction, :unit, :city, :state]
    assert nyi.sep_map.select{|data| data[:text] == 'Washington'}.first[:from_location] == [:city, :state]
    assert nyi.sep_map.select{|data| data[:text] == 'DC'}.first[:from_location] == [:state, :postal_code]
    assert nyi.sep_map.select{|data| data[:text] == '20202'}.first[:from_location] == [:state, :postal_code, :country]
  end

  def test_consolidate_identity_options
    nyi = NYIdentifier.new
    nyi.str = '1600 Pennsylvania Ave NE, Washington, DC 20202'
    nyi.clean_string
    nyi.separate
    nyi.create_sep_map
    nyi.identify_all_by_pattern
    nyi.identify_all_by_location
    nyi.consolidate_identity_options
    assert nyi.sep_map.select{|data| data[:text] == '1600'}.first[:in_both] == [:street_number, :street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Pennsylvania'}.first[:in_both] == [:street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Ave'}.first[:in_both] == [:street_name, :street_label]
    assert nyi.sep_map.select{|data| data[:text] == 'NE'}.first[:in_both] == [:street_name, :street_direction, :city, :state]
    assert nyi.sep_map.select{|data| data[:text] == 'Washington'}.first[:in_both] == [:city, :state]
    assert nyi.sep_map.select{|data| data[:text] == 'DC'}.first[:in_both] == [:state]
    assert nyi.sep_map.select{|data| data[:text] == '20202'}.first[:in_both] == [:postal_code]
  end

  def test_strip_identity_options
    nyi = NYIdentifier.new
    # nyi.str = '1600 Pennsylvania Ave NE, Washington, DC 20202'
    # nyi.str = '4933 Yukon Ave N New Hope MN'
    nyi.str = '5301 Radford Rd, Water Town, South Dakota, USA'
    nyi.clean_string
    nyi.separate
    nyi.create_sep_map
    nyi.identify_all_by_pattern
    nyi.identify_all_by_location
    nyi.consolidate_identity_options
    nyi.strip_identity_options
    for sep in nyi.sep_map do
      puts "#{sep[:text]} - #{sep[:stripped]}"
    end

    assert nyi.sep_map.select{|data| data[:text] == '5301'}.first[:stripped] == [:street_number]
    assert nyi.sep_map.select{|data| data[:text] == 'Radford'}.first[:stripped] == [:street_name]
    assert nyi.sep_map.select{|data| data[:text] == 'Rd'}.first[:stripped] == [:street_label]
    assert nyi.sep_map.select{|data| data[:text] == 'Water'}.first[:stripped] == [:city]
    assert nyi.sep_map.select{|data| data[:text] == 'Town' }.first[:stripped] == [:city]
    assert nyi.sep_map.select{|data| data[:text] == 'South'}.first[:stripped] == [:state]
    assert nyi.sep_map.select{|data| data[:text] == 'Dakota'}.first[:stripped] == [:state]
    assert nyi.sep_map.select{|data| data[:text] == 'USA'}.first[:stripped] == [:country]
  end
end
