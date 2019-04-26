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
    assert NYAddressor.new("1600 North Pennsylvania Ave, Washington, DC, 20500").construct(nil, :prefix) == NYAddressor.new("1600 N Pennsylvania Ave, Washington, DC, 20500").construct(nil, :prefix)
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

end
