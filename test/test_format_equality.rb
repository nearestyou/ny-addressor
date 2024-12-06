require 'minitest/autorun'
require_relative '../lib/ny-addressor/parsers/generic_parser'
require_relative '../lib/ny-addressor'
require 'byebug'

class TestFormatEquality < Minitest::Test
  def test_simple_equality
    str = '1600 Penn Ave, Washington, DC, 20500'
    assert_equal NYAddressor::Addressor.new(str), NYAddressor::Addressor.new(str)
  end

  def test_case
    assert_equal(
      NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC, 20500'),
      NYAddressor::Addressor.new('1600 pENN aVE, wASHINGTON, dc, 20500'),
    )
  end

  def test_numeric
    assert_equal(
      NYAddressor::Addressor.new('1600 First Ave, Washington, DC, 20500'),
      NYAddressor::Addressor.new('1600 1st Ave, Washington, DC, 20500'),
    )
  end

  def test_periods
    assert_equal(
      NYAddressor::Addressor.new('1600 Penn Ave, Washington, D.C., 20500'),
      NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC, 20500'),
    )

    assert_equal(
      NYAddressor::Addressor.new('1600 Penn St., Washington, DC, 20500'),
      NYAddressor::Addressor.new('1600 Penn St, Washington, DC, 20500'),
    )
  end

  def test_prefix_suffix
    assert_equal(
      NYAddressor::Addressor.new('1600 North Penn Ave, Washington, DC, 20500'),
      NYAddressor::Addressor.new('1600 Penn Ave North, Washington, DC, 20500'),
    )
  end

  def test_state_abrev
    assert_equal(
      NYAddressor::Addressor.new('1600 North Penn Ave, Washington, DC, 20500'),
      NYAddressor::Addressor.new('1600 Penn Ave North, Washington, District of Columbia, 20500'),
    )
  end

  def test_country
    assert_equal(
      NYAddressor::Addressor.new('1600 North Penn Ave, Washington, DC, 20500, United States'),
      NYAddressor::Addressor.new('1600 Penn Ave North, Washington, DC, 20500'),
    )
  end

  def test_country_abrev
    assert_equal(
      NYAddressor::Addressor.new('1600 North Penn Ave, Washington, DC, 20500, United States'),
      NYAddressor::Addressor.new('1600 Penn Ave North, Washington, DC, 20500, USA'),
    )
  end

  def test_label_abrev
    assert_equal(
      NYAddressor::Addressor.new('13322 Airport Boulevard, Sugar, TX 77478'),
      NYAddressor::Addressor.new('13322 Airport Blvd, Sugar, TX 77478')
    )
  end

  def test_no_prezip_comma
    assert_equal(
      NYAddressor::Addressor.new('1600 Pennsylvania Ave, Washington, DC 20500'),
      NYAddressor::Addressor.new('1600 Pennsylvania Ave, Washington, DC, 20500')
    )
  end

  def test_double_direction
    assert_equal(
      NYAddressor::Addressor.new('232 N Main St N, Stillwater, MN 55082, USA'),
      NYAddressor::Addressor.new('232 Main St N, Stillwater, MN 55082, USA')
    )
  end

  def test_direction_as_street
    assert !NYAddressor::Addressor.new('260 North St N, Middlebury, VT 05753, USA').hash.nil?
    assert !NYAddressor::Addressor.new('901 Avenue E, Wisner, NE 68791, United States').hash.nil?
    assert !NYAddressor::Addressor.new('11030 East Blvd, Cleveland, OH 44106, United States').hash.nil?
  end

  def test_label_as_street
    assert !NYAddressor::Addressor.new('260 Court St Unit 6, Middlebury, VT 05753, USA').hash.nil?
  end

  def test_double_entry
    base = NYAddressor::Addressor.new('1600 Pennsylvania Ave, Washington, DC 20500')
    assert_equal(
      base,
      NYAddressor::Addressor.new('1600 Pennsylvania Ave, Washington, DC 20500, Washington, DC 20500')
    )
    assert_equal(
      base,
      NYAddressor::Addressor.new('1600 Pennsylvania Ave, Washington DC, DC 20500')
    )
    assert_equal(
      base,
      NYAddressor::Addressor.new('1600 Pennsylvania Ave, Washington, DC, DC 20500')
    )
  end

  def test_cross_street
    assert_equal(
      NYAddressor::Addressor.new('1600 North Pennsylvania (at 16th) Ave, Washington, DC, 20500'),
      NYAddressor::Addressor.new('1600 Pennsylvania Ave N, Washington, DC, 20500')
    )

    assert_equal(
      NYAddressor::Addressor.new('1505 & 1507 10TH AVE, SEATTLE, WA 98120'),
      NYAddressor::Addressor.new('1505 10TH AVE, SEATTLE, WA 98120'),
    )

    assert_equal(
      NYAddressor::Addressor.new('1505&1507 10TH AVE, SEATTLE, WA 98120'),
      NYAddressor::Addressor.new('1505 10TH AVE, SEATTLE, WA 98120'),
    )
  end

  def test_error
    assert_nil NYAddressor::Addressor.new(nil).hash
    assert_nil NYAddressor::Addressor.new('sad;lkjfasdkj;fjaks;df').hash
  end

  def test_zip_extension
    assert_equal(
      NYAddressor::Addressor.new('13322 Airport Blvd, Sugar, TX 77478-9898'),
      NYAddressor::Addressor.new('13322 Airport Blvd, Sugar, TX 77478')
    )
  end

  def test_leading_unit_designations
    original = NYAddressor::Addressor.new('15355 Main Ave, #700, Washington, DC 20500')
    assert_equal(
      original,
      NYAddressor::Addressor.new('700-15355 Main Ave, Washington, DC 20500')
    )
    assert_equal(
      original,
      NYAddressor::Addressor.new('700/15355 Main Ave, Washington, DC 20500')
    )
  end

  def test_unit_in_street_num
    original = NYAddressor::Addressor.new('1600 Pennsylvania Ave N, Minneapolis, MN 55555')
    assert_equal(
      original.hash,
      NYAddressor::Addressor.new('1600-A Pennsylvania Ave N, Minneapolis, MN 55555').unitless_hash
    )
    assert_equal(
      original.hash,
      NYAddressor::Addressor.new('1600A Pennsylvania Ave N, Minneapolis, MN 55555').unitless_hash
    )
  end

end
