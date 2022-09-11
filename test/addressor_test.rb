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

  def test_simple_equality
    str = '1600 Pennsylvania Ave, Washington, DC, 20500'
    assert eq(str, str)
  end

  def test_case
    assert eq('1600 Pennsylvania Ave, Washington, DC, 20500', '1600 PENNSYLVANIA Ave, Washington, DC, 20500')
  end

  def test_numeric
    assert eq('1600 First Ave, Washington, DC, 20500', '1600 1st Ave, Washington, DC, 20500')
  end

  def test_periods
    assert eq('1600 First Ave, St. Washington, D.C., 20500', '1600 First Ave, St Washington, DC, 20500')
  end

  def test_prefix_suffix
    assert eq('1600 North Pennsylvania Ave, Washington, DC, 20500', '1600 Pennsylvania Ave N, Washington, DC, 20500')
  end

  def test_state_abrev
    assert eq('1600 Pennsylvania Ave, Washington, DC, 20500', '1600 Pennsylvania Ave, Washington, District of Columbia, 20500')
  end

  def test_country
    assert eq('1600 North Pennsylvania Ave, Washington, DC, 20500, United States', '1600 Pennsylvania Ave N, Washington, DC, 20500')
    assert eq('89 Trinity Dr, Moncton, NB E1G 2J7', '89 Trinity Dr, Moncton NB E1G 2J7, Canada')
  end

  def test_country_abrev
    assert eq('1600 Pennsylvania Ave, Washington, DC, 20500, USA', '1600 Pennsylvania Ave, Washington, DC, 20500, United States of America')
  end

  def test_cross_street
    assert eq('1600 North Pennsylvania (at 16th) Ave, Washington, DC, 20500', '1600 Pennsylvania Ave N, Washington, DC, 20500')
  end

  def test_no_prezip_comma
    assert eq('1600 Pennsylvania Ave, Washington, DC 20500', '1600 Pennsylvania Ave, Washington, DC, 20500')
    assert eq('1600 Pennsylvania Ave, Washington, DC,20500', '1600 Pennsylvania Ave, Washington, DC, 20500')
    assert eq('89 Trinity Dr, Moncton NB E1G 2J7, Canada', '89 Trinity Dr, Moncton, NB E1G 2J7, Canada')
  end

  def test_double_direction
    assert eq('232 N Main St N, Stillwater, MN 55082, USA', '232 Main St N, Stillwater, MN 55082, USA')
    assert eq('232 N Main St N, Stillwater, MN 55082, USA', '232 N Main St, Stillwater, MN 55082, USA')
  end

  def test_direction_as_street
    assert !NYAddressor.new('260 North St N, Middlebury, VT 05753, USA').hash.nil?
  end

  def test_label_as_street
    assert !NYAddressor.new('260 Court St Unit 6, Middlebury, VT 05753, USA').hash.nil?
  end

  def test_double_entry
    assert eq('1600 Pennsylvania Ave, Washington, DC 20500', '1600 Pennsylvania Ave, Washington, DC 20500, Washington, DC 20500')
    assert eq('1600 Pennsylvania Ave, Washington, DC 20500', '1600 Pennsylvania Ave, Washington DC, DC 20500')
    assert eq('1600 Pennsylvania Ave, Washington, DC 20500', '1600 Pennsylvania Ave, Washington, DC, DC 20500')
  end

  def test_missing_zip
    assert eq('1600 Pennsylvania Ave, Washington, DC','1600 Pennsylvania Ave, Washington, DC 99999')
    assert eq('1600 Pennsylvania Ave, Washington DC', '1600 Pennsylvania Ave, Washington, DC 99999')
  end

  def test_missing_zip_with_comma
    assert eq('1600 Pennsylvania Ave, Washington, DC,', '1600 Pennsylvania Ave, Washington, DC 99999')
  end

  def test_missing_zip_with_country
    assert eq('1600 Pennsylvania Ave, Washington, DC, USA', '1600 Pennsylvania Ave, Washington, DC 99999, USA')
  end

  def test_city_with_number
    assert eq('1600 Pennsylvania Ave, Washington 2, DC, 99999', '1600 Pennsylvania Ave, Washington, DC 99999')
  end

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

  def test_error_parse
    assert_nil NYAddressor.new('ghjkjhghjkjhghjkjhghjkjhghjk').parts
  end

  def test_error_hash
    assert_nil NYAddressor.new('ghjkjhghjkjhghjkjhghjkjhghjk').hash
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

  def test_canadian_zip
    zip = 'H0H 0H0'
    zip_no_space = zip.delete(' ')
    assert ['h0', zip.downcase, zip_no_space.downcase].include? NYAddressor.new('1500 Bennsylvania Ave, Washington, ON ' + zip).parts[:postal]
    assert NYAddressor.new('1500 Bennsylvania Ave, Washington, ON ' + zip_no_space).hash == NYAddressor.new('1500 Bennsylvania Ave, Washington, ON ' + zip).hash
  end

  def test_determine_state
    assert NYAddressor.determine_state('Minnesota') == 'MN'
    assert NYAddressor.determine_state('Ontario') == 'ON'
  end

  def test_full_state
    assert eq('1600 Pennsylvania Ave, Washington, Iowa, 20500', '1600 Pennsylvania Ave, Washington, IA, 20500')
    assert eq('1600 Pennsylvania Ave, Washington, Manitoba, M3M 5T5', '1600 Pennsylvania Ave, Washington, MB, M3M 5T5')
  end

  def test_duplicate_entries
    assert eq('611 E 30th Ave, Spokane, WA 99203, USA, Spokane, WA 99203, USA', '611 E 30th Ave, Spokane, WA, 99203')
    # assert eq('611 E 30th Ave, Spokane, WA 99203, USA, Spokane, WA 99203, United States', '611 E 30th Ave, Spokane, WA, 99203')
  end

  def test_ohs_in_zip
    assert eq('1600 First Ave, Washington, DC, 20500', '1600 First Ave, Washington, DC, 205Oo')
  end

  def test_empty_array_entries
    assert eq('1600 First Ave, Washington, DC, 20500', '1600 First Ave,, Washington, DC, 20500')
  end

  def test_boulevard
    assert eq('13322 West Airport Boulevard, Sugar Land, TX 77478', '13322 Airport Blvd W, Sugar Land, TX 77478')
  end

  def test_missing
    assert NYAddressor.new(nil).hash.nil?
  end

  def test_double_comma
    assert eq('602 21st r  NW, portland,, or 97209', '602 21st r  NW, portland, or 97209')
  end

  def test_zip_extension
    assert eq('13322 West Airport Boulevard, Sugar Land, TX 77478-9898', '13322 Airport Blvd W, Sugar Land, TX 77478')
    assert eq('13322 West Airport Boulevard, Sugar Land, TX 774789898', '13322 Airport Blvd W, Sugar Land, TX 77478')
  end

  def test_unknown_errors
    assert eq('1337 14th St NW (at Rhode Island Ave NW), Washington, D.C. 20005, United States', '1337 14th St NW, Washington, DC, 20005')
  end

  def test_missing_unit_designation
    assert eq('15355 24 Ave,700 (at Peninsula Village), Surrey BC V4A 2H9, Canada', '15355 24 Ave,#700 (at Peninsula Village), Surrey BC V4A 2H9, Canada')
  end

  def test_leading_unit_designations
    assert eq('700-15355 Main Ave, Surrey BC V4A 2H9, Canada', '15355 Main Ave,#700, Surrey BC V4A 2H9, Canada')
    assert eq('700/15355 Main Ave, Surrey BC V4A 2H9, Canada', '15355 Main Ave,#700, Surrey BC V4A 2H9, Canada')
  end

  def test_definition_of_sns
    # street number, name, state
    assert NYAddressor.new('1600 First Ave, Washington, DC, 20500').sns == '16001stdc'
    assert NYAddressor.new('1600 1st Ave, Washington, DC, 20500').sns == '16001stdc'
  end

  def test_highways
    assert NYAddressor.new('21317 OR99E,AURORA,OR,97002').sns == '21317or99eor'
    assert NYAddressor.new('21317 OR-99E,AURORA,OR,97002').sns == '21317or99eor'
    assert NYAddressor.new('7902 Highway 23, Belle Chasse, LA 70037, United States').sns == '790223la'
    assert NYAddressor.new('5801 Sunrise Hwy, Holbrook, NY 11741, USA').sns == '5801sunriseny'
  end

  def test_ste
    assert eq('15355 Main Ave #456, Surrey, MN, 55082', '15355 Main Ave STE 456, Surrey, MN, 55082')
    assert eq('9810 Medlock Bridge Rd Suite 500, Johns Creek, GA 30097, USA', '9810 Medlock Bridge Rd #500, Johns Creek, GA 30097, USA')
    assert !NYAddressor.new('15355 Main Ave STE G&H, Surrey, MN, 55082').hash.nil?
  end

  def test_two_adjacent_locations
    assert eq('1505 & 1507 10TH AVE, SEATTLE, WA 98120', '1507 10TH AVE, SEATTLE, WA 98120')
    assert eq('1505&1507 10TH AVE, SEATTLE, WA 98120', '1507 10TH AVE, SEATTLE, WA 98120')
  end

  def test_missing_street_number
    assert NYAddressor.new('Main St,AURORA,OR,97002').sns == ''
  end

  def test_wisconsin_addresses
    assert NYAddressor.new('W204N11912 Goldendale Rd,AURORA,OR,97002').sns == 'w204n11912goldendaleor'
    assert NYAddressor.new('W204 N11912 Goldendale Rd,AURORA,OR,97002').sns == 'w204n11912goldendaleor'
  end

  def test_expressway_abbreviation
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main Express way,AURORA,OR,97002').hash
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main Expressway,AURORA,OR,97002').hash
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main EXPWY,AURORA,OR,97002').hash
    assert NYAddressor.new('333 Main Expy,AURORA,OR,97002').hash == NYAddressor.new('333 Main EXWY,AURORA,OR,97002').hash
  end

  def test_unitless_hash
    assert NYAddressor.new('1600 Pennsylvania Ave #3, Washington, DC, 20500').unitless_hash == NYAddressor.new( '1600 Pennsylvania Ave, Washington, DC, 20500').hash
    assert NYAddressor.new('1600 Pennsylvania Ave, APT 3, Washington, DC, 20500').unitless_hash == NYAddressor.new( '1600 Pennsylvania Ave, Washington, DC, 20500').hash
    assert NYAddressor.new('1600 Pennsylvania Ave Ste 3, Washington, DC, 20500').unitless_hash == NYAddressor.new( '1600 Pennsylvania Ave, Washington, DC, 20500').hash
  end

  def test_canadian_hiway
    assert NYAddressor.new('2070 BC-3, Cawston, BC V0X 1C2, Canada').sns == '2070bc3bc'
  end

  def test_pre_unit
    assert NYAddressor.new('B2 - 15562 24TH AVENUE, SURREY, V4A2J5').unitless_hash == NYAddressor.new('15562 24TH AVENUE, SURREY, V4A2J5').hash
    assert NYAddressor.new('UNIT 23 11151 HORSESHOE WAY, RICHMOND, V7A4S5').unitless_hash == NYAddressor.new('11151 HORSESHOE WAY, RICHMOND, V7A4S5').hash
    assert NYAddressor.new('150 - 19288 22ND AVENUE, SURREY, V3S3S9').unitless_hash == NYAddressor.new('19288 22ND AVENUE, SURREY, V3S3S9').hash
  end

  def test_unit_in_street_num
    assert NYAddressor.new('1600A Pennsylvania Ave N, New Minneapolis, MN 55555').unitless_hash  == NYAddressor.new('1600 Pennsylvania Ave N, New Minneapolis, MN 55555').hash
    assert NYAddressor.new('1600-A Pennsylvania Ave N, New Minneapolis, MN 55555').unitless_hash == NYAddressor.new('1600 Pennsylvania Ave N, New Minneapolis, MN 55555').hash
    assert NYAddressor.new('12015-B, Rockville Pike, Rockville, MD 20852, United States').unitless_hash == NYAddressor.new('12015, Rockville Pike, Rockville, MD 20852, United States').hash
  end

  #  def test_dutch_saint
  #    addy = NYAddressor.new('79 Bush Road, Simpson Bay, Sint Maarten')
  #    assert addy.addressor.parts[:state] == 'sint maarten' # or should this be st maarten
  #    assert addy.addressor.parts[:city] == 'simpson bay'
  #  end

  def test_canadian_boul
    assert NYAddressor.new('5850 boul. Jean XXIII, Trois-Rivières, QC, G8Z 4B5').parts[:street_label] == 'blvd'
  end

  def test_previous_errors
    assert NYAddressor.new('Perkins Rd. & Rouzan Ave. 4841 Rouzan Square Ave, Baton Rouge, LA 70808')
  end
end
