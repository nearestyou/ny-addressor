require 'minitest/autorun'
load 'lib/ny-addressor.rb'

class NYAddressorTest < MiniTest::Test
  def eq(str1, str2)
    address = NYAddressor.new(str1)
    address.eq(NYAddressor.new(str2).parse, true)
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

end
