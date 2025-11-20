# frozen_string_literal: true
require "test_helper"

class AddressEquivalenceTest < Minitest::Test

  def test_simple_equality_same_string
    str = "1600 Penn Ave, Washington, DC, 20500"
    assert_same_full str, str
  end

  def test_different_street_number
    str1 = "1600 Penn Ave, Washington, DC, 20500"
    str2 = "1601 Penn Ave, Washington, DC, 20500"
    refute_same_full str1, str2
  end

  def test_numeric_full_equivalence
    assert_same_full(
      '1600 First Ave, Washington, DC, 20500',
      '1600 1st Ave, Washington, DC, 20500',
    )
  end


  def test_periods
    assert_same_full(
      '1600 Penn Ave, Washington, D.C., 20500',
      '1600 Penn Ave, Washington, DC, 20500',
    )

    assert_same_full(
      '1600 Penn St., Washington, DC, 20500',
      '1600 Penn St, Washington, DC, 20500',
    )
  end

  def test_prefix_suffix
    assert_same_full(
      '1600 North Penn Ave, Washington, DC, 20500',
      '1600 Penn Ave North, Washington, DC, 20500',
    )
  end

  def test_state_abrev
    assert_same_full(
      '1600 North Penn Ave, Washington, DC, 20500',
      '1600 Penn Ave North, Washington, District of Columbia, 20500',
    )
  end

  def test_country
    assert_same_countryless(
      '1600 North Penn Ave, Washington, DC, 20500, United States',
      '1600 Penn Ave North, Washington, DC, 20500',
    )
  end

  def test_country_abrev
    assert_same_full(
      '1600 North Penn Ave, Washington, DC, 20500, United States',
      '1600 Penn Ave North, Washington, DC, 20500, USA',
    )

    assert_same_full(
      '1600 North Penn Ave, Washington, DC, 20500, United States of America',
      '1600 Penn Ave North, Washington, DC, 20500, United States',
    )
  end


  def test_label_abrev
    assert_same_full(
      '13322 Airport Boulevard, Sugar, TX 77478',
      '13322 Airport Blvd, Sugar, TX 77478'
    )
  end

  def test_no_prezip_comma
    assert_same_full(
      '1600 Pennsylvania Ave, Washington, DC 20500',
      '1600 Pennsylvania Ave, Washington, DC, 20500'
    )
  end

  def test_double_direction
    assert_same_full(
      '232 North Main St N, Stillwater, MN 55082, USA',
      '232 Main St N, Stillwater, MN 55082, USA'
    )
  end

  
  def test_direction_as_street
    assert !NYAddressor.process('901 Avenue E, Wisner, NE 68791, United States').fingerprints[:full].nil?
    assert !NYAddressor.process('260 North St N, Middlebury, VT 05753, USA').fingerprints[:full].nil?
    assert !NYAddressor.process('11030 East Blvd, Cleveland, OH 44106, United States').fingerprints[:full].nil?
  end

  def test_label_as_street
    assert !NYAddressor.process('260 Court St Unit 6, Middlebury, VT 05753, USA').fingerprints[:full].nil?
    assert !NYAddressor.process('2656 Parkway, Pigeon Forge, TN 37863, United States').fingerprints[:full].nil?

    assert_same_full(
      '260 Court St Unit 6, Middlebury, VT 05753, USA',
      '260 Court Street Unit 6, Middlebury, VT 05753, USA'
    )
  end

  def test_number_as_street
    assert !NYAddressor.process('1600 24 Ave, Washington, DC 20500').fingerprints[:full].nil?
  end

  def test_double_entry
    base = '1600 Pennsylvania Ave, Washington, DC 20500'
    assert_same_full(
      base,
      '1600 Pennsylvania Ave, Washington, DC 20500, Washington, DC 20500'
    )
    assert_same_full(
      base,
      '1600 Pennsylvania Ave, Washington DC, DC 20500'
    )
    assert_same_full(
      base,
      '1600 Pennsylvania Ave, Washington, DC, DC 20500'
    )

    assert(!NYAddressor.process('4051 Broadway, New York, NY 10032, United States').fingerprints[:full].nil?)
  end

  def test_double_comma
    assert_same_full(
      '602 21st r  NW, portland,, or 97209',
      '602 21st r  NW, portland, or 97209',
    )

    assert_same_full(
      '602 21st r  NW,, portland, or 97209',
      '602 21st r  NW, portland, or 97209',
    )
  end

  def test_cross_street
    assert_same_full(
      '1600 North Pennsylvania (at 16th) Ave, Washington, DC, 20500',
      '1600 Pennsylvania Ave N, Washington, DC, 20500'
    )
    assert_same_full(
      '1505 & 1507 10TH AVE, SEATTLE, WA 98120',
      '1505 10TH AVE, SEATTLE, WA 98120',
    )

    assert_same_full(
      '1505&1507 10TH AVE, SEATTLE, WA 98120',
      '1505 10TH AVE, SEATTLE, WA 98120',
    )
  end

  def test_error
    assert_nil NYAddressor.process(nil).fingerprints[:full]
    assert_nil NYAddressor.process('sad;lkjfasdkj;fjaks;df').fingerprints[:full]
  end


  def test_zip_extension
    assert_same_full(
      '13322 Airport Blvd, Sugar, TX 77478-9898',
      '13322 Airport Blvd, Sugar, TX 77478'
    )
  end

  def test_unit_designations
    assert_same_full(
      '15355 Main Ave, Unit 700, Washington, DC 20500',
      '15355 Main Ave, Apt 700, Washington, DC 20500'
    )
  end

  def test_leading_unit_designations
    original = '15355 Main Ave, #700, Washington, DC 20500'
    assert_same_full(
      original,
      '700-15355 Main Ave, Washington, DC 20500'
    )
    assert_same_full(
      original,
      '700/15355 Main Ave, Washington, DC 20500'
    )
  end

  def test_missing_unit_designation
    assert_same_full(
      '1600 Pennsylvania Ave 700, Minneapolis, MN 55555',
      '1600 Pennsylvania Ave #700, Minneapolis, MN 55555',
    )
  end

  def test_unit_in_street_num
    original = '1600 Pennsylvania Ave N, Minneapolis, MN 55555'
    with_dash = '1600-A Pennsylvania Ave N, Minneapolis, MN 55555'
    dashless = '1600A Pennsylvania Ave N, Minneapolis, MN 55555'

    assert_unitless_equivalent(original, with_dash)
    assert_unitless_equivalent(original, dashless)
    assert_same_full(with_dash, dashless)
  end

  def test_unit_formats
    numberless  = 'Pennsylvania Ave N, Minneapolis, MN 55555'
    full        = "1600 #{numberless}"
    lead        = "B2 1600 #{numberless}"
    lead_dash   = "B2-1600 #{numberless}"
    lead_space  = "B2 - 1600 #{numberless}"
    trail       = "1600 B2 #{numberless}"
    trail_dash  = "1600-B2 #{numberless}"
    trail_space = "1600 - B2 #{numberless}"

    assert_unitless_equivalent(full, lead)
    assert_unitless_equivalent(full, lead_dash, "B2- not recognized as unit")
    assert_unitless_equivalent(full, lead_space, "B2 - not recognized as unit")
    assert_unitless_equivalent(full, trail)
    assert_unitless_equivalent(full, trail_dash, "-B2 not recognized as unit")
    assert_unitless_equivalent(full, trail_space, "- B2 not recognized as unit")
  end

  def test_unit_order
    numberless   = 'Pennsylvania Ave N, Minneapolis, MN 55555'
    alphanumeric = "B2 1600 #{numberless}"
    numericalpha = "2B 1600 #{numberless}"

    assert_same_full(alphanumeric, numericalpha)
  end

  def test_leading_description
    description = 'Jacksonville International Airport'
    base_address = '2400 Yankee Clipper Dr, Jacksonville, FL 32218, United States'
    assert_same_full(
      base_address,
      "#{description}, #{base_address}",
    )
  end

  def test_missing_zip
    zipless = '1600 Pennsylvania Ave, Washington, DC'
    zip = zipless + ' 55555'
    assert_same_zipless(
      zipless,
      zip,
    )
  end

  def test_saint
    assert_same_full(
      '161 Victoria St N, Saint Paul, MN 55104',
      '161 Victoria St N, St. Paul, MN 55104'
    )
  end

end

