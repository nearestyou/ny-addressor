require 'minitest/autorun'
require_relative '../lib/ny-addressor/parsers/generic_parser'
require_relative '../lib/ny-addressor'
require 'byebug'

class TestFormatEquality < Minitest::Test
  def test_simple_equality
    str = '1600 Penn Ave, Washington, DC, 20500'
    assert_equal NYAddressor::Addressor.new(str, :US), NYAddressor::Addressor.new(str, :US)
  end

  def test_case
    assert_equal(
      NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC, 20500', :US),
      NYAddressor::Addressor.new('1600 pENN aVE, wASHINGTON, dc, 20500', :US),
    )
  end

  def test_numeric
    assert_equal(
      NYAddressor::Addressor.new('1600 First Ave, Washington, DC, 20500', :US),
      NYAddressor::Addressor.new('1600 1st Ave, Washington, DC, 20500', :US),
    )
  end

  def test_periods
    assert_equal(
      NYAddressor::Addressor.new('1600 Penn Ave, Washington, D.C., 20500', :US),
      NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC, 20500', :US),
    )

    assert_equal(
      NYAddressor::Addressor.new('1600 Penn St., Washington, DC, 20500', :US),
      NYAddressor::Addressor.new('1600 Penn St, Washington, DC, 20500', :US),
    )
  end

  def test_prefix_suffix
    assert_equal(
      NYAddressor::Addressor.new('1600 North Penn Ave, Washington, DC, 20500', :US),
      NYAddressor::Addressor.new('1600 Penn Ave North, Washington, DC, 20500', :US),
    )
  end

  def test_state_abrev
    assert_equal(
      NYAddressor::Addressor.new('1600 North Penn Ave, Washington, DC, 20500', :US),
      NYAddressor::Addressor.new('1600 Penn Ave North, Washington, District of Columbia, 20500', :US),
    )
  end
end
