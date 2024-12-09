require 'minitest/autorun'
require 'byebug'
ENV['LOCAL_DEPENDENCIES'] = 'true'
load 'lib/ny-addressor.rb'

class NYAddressorTest < MiniTest::Test
  def eq(str1, str2)
    NYAddressor.new(str1).hash == NYAddressor.new(str2).hash
  end

  def comp(str1, str2)
    address = NYAddressor.new(str1)
    address.comp(NYAddressor.new(str2))
  end

  ############

  def test_great_match
    assert_equal comp( '1600 Pennsylvania Ave, Washington, DC 20500',  '1600 Pennsylvania Ave, Washington, DC 20500'), 3
  end

  def test_okay_match
    assert_equal comp( '1500 Pennsylvania Ave, Washington, DC 20500',  '1600 Pennsylvania Ave, Washington, DC 20500'), 2
  end

  def test_bad_match
    assert_equal comp( '1500 Bennsylvania Ave, Washington, DC 20500',  '1600 Pennsylvania Ave, Washington, DC 20500'), 1
  end

  def test_non_match
    assert_equal comp( '1500 Bennsylvania Ave, Washington, DC 20400',  '1600 Pennsylvania Ave, Washington, DC 20500'), 0
  end

  def test_error_match
    assert_equal comp( '1500 Bennsylvania Ave, Washington, DC 20400', 'kjhghjkjhghjkjhg'), 0
    assert_equal comp( 'kjhghjkjhghjkjhg', '1500 Bennsylvania Ave, Washington, DC 20400'), 0
  end

  def test_perfect_name_inclusion
    assert_equal NYAddressor.string_inclusion('THE TAVERN BAR', 'The Tavernbar'), 1
    assert_equal NYAddressor.string_inclusion('ASDF', 'The Tavernbar'), 0
  end

  def test_imperfect_name_inclusion
    assert_equal NYAddressor.string_inclusion('THE TAVERN BEAR', 'The Tavernbar', numeric_failure: true), 10.0 / 12
    assert_equal NYAddressor.string_inclusion('THE TAVERN BEAR', 'The Tavernbar on 1st Ave', numeric_failure: true), 10.0 / 13
    assert_equal NYAddressor.string_inclusion('THE TAVORN BAR', 'The Tavernbar', numeric_failure: true), 6.0 / 12
    assert_equal NYAddressor.string_inclusion('Zoo', 'The Tavernbar', numeric_failure: true), 0.0 / 3
    assert_equal NYAddressor.string_inclusion('Zoe', 'The Tavernbar', numeric_failure: true), 1.0 / 3
  end

  def test_ohs_in_zip
    assert eq('1600 First Ave, Washington, DC, 20500', '1600 First Ave, Washington, DC, 205Oo')
  end

  def test_empty_array_entries
    assert eq('1600 First Ave, Washington, DC, 20500', '1600 First Ave,, Washington, DC, 20500')
  end


  def test_highways
    assert NYAddressor.new('21317 OR99E,AURORA,OR,97002').sns == '21317or99eor'
    assert NYAddressor.new('21317 OR-99E,AURORA,OR,97002').sns == '21317or99eor'
    assert NYAddressor.new('7902 Highway 23, Belle Chasse, LA 70037, United States').sns == '790223la'
    assert NYAddressor.new('5801 Sunrise Hwy, Holbrook, NY 11741, USA').sns == '5801sunriseny'
  end


  def test_expressway_abbreviation
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main Express way,AURORA,OR,97002').hash
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main Expressway,AURORA,OR,97002').hash
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main EXPWY,AURORA,OR,97002').hash
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main EXWY,AURORA,OR,97002').hash
  end

  def test_special_characters
    assert !NYAddressor.new('&#34;N72 W13400 LUND LN SUITE&#34;,MENOMONEE FALLS,WI,53051').hash.nil?
  end

  def test_previous_errors
    assert NYAddressor.new('Perkins Rd. & Rouzan Ave. 4841 Rouzan Square Ave, Baton Rouge, LA 70808')
    assert !NYAddressor.new('14351 104 Ave, Surrey, BC V3T 1Y1, Canada').hash.nil?
    assert !NYAddressor.new('13526 106 Ave, Surrey, BC V3T 2C5, Canada').hash.nil?
  end


end
