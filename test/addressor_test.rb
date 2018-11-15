require 'minitest/autorun'
load 'lib/ny-addressor.rb'

class NYAddressorTest < MiniTest::Test
  def eq(str1, str2)
    address = NYAddressor.new(str1)
    address.eq(NYAddressor.new(str2).parse, true)
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

  def test_country
    assert eq( "1600 North Pennsylvania Ave, Washington, DC, 20500, United States",  "1600 Pennsylvania Ave N, Washington, DC, 20500")
  end

  def test_cross_street
    assert eq( "1600 North Pennsylvania (at 16th) Ave, Washington, DC, 20500",  "1600 Pennsylvania Ave N, Washington, DC, 20500")
  end

  def test_no_prezip_comma
    assert eq( "1600 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC, 20500")
  end

  def test_double_entry
    assert eq( "1600 Pennsylvania Ave, Washington, DC 20500",  "1600 Pennsylvania Ave, Washington, DC 20500, Washington, DC 20500")
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

end
