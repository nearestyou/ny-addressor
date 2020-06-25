require 'minitest/autorun'
load 'lib/ny-addressor.rb'

class NYAddressorTest < MiniTest::Test
  def eq(str1, str2)
    address = NYAddressor.new(str1)
    address.eq(NYAddressor.new(str2).parsed, true)
  end

  def comp(str1, str2)
    address = NYAddressor.new(str1)
    address.comp(NYAddressor.new(str2).parse)
  end

  def test_simple_equality
    str = "1600 Pennsylvania Ave, Washington, DC, 20500"
    assert eq(str, str)
  end

  def test_case
    assert eq( "1600 Pennsylvania Ave, Washington, DC, 20500",  "1600 PENNSYLVANIA Ave, Washington, DC, 20500")
  end

  def test_numeric
    assert eq( "1600 First Ave, Washington, DC, 20500",  "1600 1st Ave, Washington, DC, 20500")
  end

  def test_periods
    assert eq( "1600 First Ave, St. Washington, D.C., 20500",  "1600 First Ave, St Washington, DC, 20500")
  end

  def test_prefix_suffix
    assert eq( "1600 North Pennsylvania Ave, Washington, DC, 20500",  "1600 Pennsylvania Ave N, Washington, DC, 20500")
  end

  def test_prefix_only
    assert NYAddressor.new("1600 North Pennsylvania Ave, Washington, DC, 20500").construct({fix: :prefix}) == NYAddressor.new("1600 N Pennsylvania Ave, Washington, DC, 20500").construct({fix: :prefix})
  end

  def test_country
    assert eq( "1600 North Pennsylvania Ave, Washington, DC, 20500, United States",  "1600 Pennsylvania Ave N, Washington, DC, 20500")
    assert eq("89 Trinity Dr, Moncton, NB E1G 2J7","89 Trinity Dr, Moncton NB E1G 2J7, Canada")
  end

  def test_cross_street
    assert eq( "1600 North Pennsylvania (at 16th) Ave, Washington, DC, 20500",  "1600 Pennsylvania Ave N, Washington, DC, 20500")
  end

  def test_no_prezip_comma
    assert eq( "1600 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC, 20500")
    assert eq( "1600 Pennsylvania Ave, Washington, DC,20500",  "1600 Pennsylvania Ave, Washington, DC, 20500")
    assert eq("89 Trinity Dr, Moncton NB E1G 2J7, Canada","89 Trinity Dr, Moncton, NB E1G 2J7, Canada")
  end

  def test_double_entry
    assert eq( "1600 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC 20500, Washington, DC 20500")
    assert eq( "1600 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington DC, DC 20500")
    assert eq( "1600 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC, DC 20500")
  end

  def test_missing_zip
    assert eq( "1600 Pennsylvania Ave, Washington, DC",  "1600 Pennsylvania Ave, Washington, DC 99999")
    assert eq( "1600 Pennsylvania Ave, Washington DC",  "1600 Pennsylvania Ave, Washington, DC 99999")
  end

  def test_missing_zip_with_comma
    assert eq( "1600 Pennsylvania Ave, Washington, DC,",  "1600 Pennsylvania Ave, Washington, DC 99999")
  end

  def test_missing_zip_with_country
    assert eq( "1600 Pennsylvania Ave, Washington, DC, USA",  "1600 Pennsylvania Ave, Washington, DC 99999, USA")
  end

  def test_city_with_number
    assert eq( "1600 Pennsylvania Ave, Washington 2, DC, 99999",  "1600 Pennsylvania Ave, Washington, DC 99999")
  end

  def test_great_match
    assert_equal comp( "1600 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC 20500"), 3
  end

  def test_okay_match
    assert_equal comp( "1500 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC 20500"), 2
  end

  def test_bad_match
    assert_equal comp( "1500 Bennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC 20500"), 1
  end

  def test_non_match
    assert_equal comp( "1500 Bennsylvania Ave, Washington, DC 20400",  "1600 Pennsylvania Ave, Washington, DC 20500"), 0
  end

  def test_error_match
    assert_equal comp( '1500 Bennsylvania Ave, Washington, DC 20400', 'kjhghjkjhghjkjhg'), 0
    assert_equal comp( 'kjhghjkjhghjkjhg', '1500 Bennsylvania Ave, Washington, DC 20400'), 0
  end

  def test_error_parse
    assert_nil NYAddressor.new('ghjkjhghjkjhghjkjhghjkjhghjk').parse
  end

  def test_error_hash
    assert_nil NYAddressor.new('ghjkjhghjkjhghjkjhghjkjhghjk').hash
  end

  def test_perfect_name_inclusion
    assert_equal NYAddressor.string_inclusion('THE TAVERN BAR', 'The Tavernbar'), 1
    assert_equal NYAddressor.string_inclusion('ASDF', 'The Tavernbar'), 0
  end

  def test_imperfect_name_inclusion
    assert_equal NYAddressor.string_inclusion('THE TAVERN BEAR', 'The Tavernbar', true), 10.0/12
    assert_equal NYAddressor.string_inclusion('THE TAVERN BEAR', 'The Tavernbar on 1st Ave', true), 10.0/13
    assert_equal NYAddressor.string_inclusion('THE TAVORN BAR', 'The Tavernbar', true), 6.0/12
    assert_equal NYAddressor.string_inclusion('Zoo', 'The Tavernbar', true), 0.0/3
    assert_equal NYAddressor.string_inclusion('Zoe', 'The Tavernbar', true), 1.0/3
  end

  def test_canadian_zip
    zip = 'H0H 0H0'
    assert NYAddressor.new('1500 Bennsylvania Ave, Washington, ON ' + zip).zip == zip
  end

  def test_determine_state
    assert NYAddressor.determine_state('Minnesota') == 'MN'
    assert NYAddressor.determine_state('Ontario') == 'ON'
  end

  def test_full_state
    assert eq( "1600 Pennsylvania Ave, Washington, Iowa, 20500",  "1600 Pennsylvania Ave, Washington, IA, 20500")
    assert eq( "1600 Pennsylvania Ave, Washington, Manitoba, M3M 5T5",  "1600 Pennsylvania Ave, Washington, MB, M3M 5T5")
  end

  def test_duplicate_entries
    assert eq("611 E 30th Ave, Spokane, WA 99203, USA, Spokane, WA 99203, USA", "611 E 30th Ave, Spokane, WA, 99203")
    assert eq("611 E 30th Ave, Spokane, WA 99203, USA, Spokane, WA 99203, United States", "611 E 30th Ave, Spokane, WA, 99203")
  end

  def test_ohs_in_zip
    assert eq( "1600 First Ave, Washington, DC, 20500",  "1600 First Ave, Washington, DC, 205Oo")
  end

  def test_empty_array_entries
    assert eq( "1600 First Ave, Washington, DC, 20500",  "1600 First Ave,, Washington, DC, 20500")
  end

  def test_boulevard
    assert eq( "13322 West Airport Boulevard, Sugar Land, TX 77478",  "13322 Airport Blvd W, Sugar Land, TX 77478")
  end

  def test_missing
    assert NYAddressor.new(nil).hash.nil?
  end

  def test_double_comma
    assert eq("602 21st r  NW, portland,, or 97209","602 21st r  NW, portland, or 97209")
  end

  def test_zip_extension
    assert eq( "13322 West Airport Boulevard, Sugar Land, TX 77478-9898",  "13322 Airport Blvd W, Sugar Land, TX 77478")
    assert eq( "13322 West Airport Boulevard, Sugar Land, TX 774789898",  "13322 Airport Blvd W, Sugar Land, TX 77478")
  end

  def test_unknown_errors
    assert eq("1337 14th St NW (at Rhode Island Ave NW), Washington, D.C. 20005, United States","1337 14th St NW, Washington, DC, 20005")
  end

  def test_missing_unit_designation
    assert eq("15355 24 Ave,700 (at Peninsula Village), Surrey BC V4A 2H9, Canada", "15355 24 Ave,#700 (at Peninsula Village), Surrey BC V4A 2H9, Canada")
  end

  def test_non_demarcated_unit_designation
    assert eq("9810 Medlock Bridge Rd Suite 500, Johns Creek, GA 30097, USA", "9810 Medlock Bridge Rd #500, Johns Creek, GA 30097, USA")
  end

  def test_leading_unit_designations
    assert eq("700-15355 Main Ave, Surrey BC V4A 2H9, Canada", "15355 Main Ave,#700, Surrey BC V4A 2H9, Canada")
    assert eq("700/15355 Main Ave, Surrey BC V4A 2H9, Canada", "15355 Main Ave,#700, Surrey BC V4A 2H9, Canada")
  end

  def test_definition_of_sns # street, number, state
    assert NYAddressor.new( "1600 First Ave, Washington, DC, 20500").sns == '16001stdc'
    assert NYAddressor.new( "1600 1st Ave, Washington, DC, 20500").sns == '16001stdc'
  end

  def test_highways
    assert NYAddressor.new("21317 OR99E,AURORA,OR,97002").sns == '21317or99eor'
    assert NYAddressor.new("21317 OR-99E,AURORA,OR,97002").sns == '21317or99eor'
  end

  def test_STE
    assert eq("15355 Main Ave #456, Surrey, MN, 55082", "15355 Main Ave STE 456, Surrey, MN, 55082")
    assert !NYAddressor.new("15355 Main Ave STE G&H, Surrey, MN, 55082").hash.nil?
  end

  def test_two_adjacent_locations
    assert eq("1505 & 1507 10TH AVE, SEATTLE, WA 98120", "1507 10TH AVE, SEATTLE, WA 98120")
    assert eq("1505&1507 10TH AVE, SEATTLE, WA 98120", "1507 10TH AVE, SEATTLE, WA 98120")
  end

  def test_missing_street_number
    assert NYAddressor.new("Main St,AURORA,OR,97002").sns == ''
  end

  def test_wisconsin_addresses
    #assert NYAddressor.new("W204N11912 Goldendale Rd,AURORA,OR,97002").sns == 'w204n11912goldendaleor'
    assert NYAddressor.new("W204 N11912 Goldendale Rd,AURORA,OR,97002").sns == 'w204n11912goldendaleor'
  end

  def test_expressway_abbreviation
    assert NYAddressor.new("333 Main Expy,AURORA,OR,97002").hash == NYAddressor.new("333 Main Express way,AURORA,OR,97002").hash
    assert NYAddressor.new("333 Main Expy,AURORA,OR,97002").hash == NYAddressor.new("333 Main Expressway,AURORA,OR,97002").hash
    assert NYAddressor.new("333 Main Expy,AURORA,OR,97002").hash == NYAddressor.new("333 Main EXPWY,AURORA,OR,97002").hash
    assert NYAddressor.new("333 Main Expy,AURORA,OR,97002").hash == NYAddressor.new("333 Main EXWY,AURORA,OR,97002").hash
  end

  def test_unitless_hash
    assert NYAddressor.new( "1600 Pennsylvania Ave #3, Washington, DC, 20500").unitless_hash == NYAddressor.new( "1600 Pennsylvania Ave, Washington, DC, 20500").hash
    assert NYAddressor.new( "1600 Pennsylvania Ave, APT 3, Washington, DC, 20500").unitless_hash == NYAddressor.new( "1600 Pennsylvania Ave, Washington, DC, 20500").hash
    assert NYAddressor.new( "1600 Pennsylvania Ave Ste 3, Washington, DC, 20500").unitless_hash == NYAddressor.new( "1600 Pennsylvania Ave, Washington, DC, 20500").hash
  end

  def test_canadian_hiway
    assert NYAddressor.new("2070 BC-3, Cawston, BC V0X 1C2, Canada").sns == "2070bc3bc"
  end

end
