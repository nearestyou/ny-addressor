require 'minitest/autorun'
require_relative '../lib/ny-addressor'
require_relative '../lib/ny-addressor/constants'
require 'byebug'

class TestRegions < Minitest::Test
  def setup
    @fields = NYAddressor::AddressField
    @postals = NYAddressor::Constants::POSTAL_FORMATS
  end

  def test_us_postal_format
    assert_match @postals[:US], "12345"
    assert_match @postals[:US], "12345-6789"
    assert_match @postals[:US], "123456789"
    refute_match @postals[:US], "AA12345BB"
    refute_match @postals[:US], "1234"
    refute_match @postals[:US], "123456"
  end

  def test_ca_postal_format
    assert_match @postals[:CA], "A1B 2C3"
    refute_match @postals[:CA], "SW1A 2BC"
    refute_match @postals[:CA], "12345"
  end

  def test_uk_postal_format
    assert_match @postals[:UK], "SW1W 0NY"
    assert_match @postals[:UK], "PO16 7GZ"
    assert_match @postals[:UK], "GU16 7HF"
    assert_match @postals[:UK], "L1 8JQ"

    refute_match @postals[:UK], "A1B 2C3"
    refute_match @postals[:UK], "12345"
  end

  def test_au_postal_format
    assert_match @postals[:AU], "1234"
    refute_match @postals[:AU], "12345"
  end

  def test_wisconsin_addresses
    assert NYAddressor::Addressor.new('W204N11912 Goldendale Rd,AURORA,Wi,97002').sns == 'w204n11912goldendalewi'
    assert NYAddressor::Addressor.new('W204 N11912 Goldendale Rd,AURORA,Wi,97002').sns == 'w204n11912goldendalewi'
  end

  def test_puerto_rican
    assert !NYAddressor::Addressor.new('1310 Ashford Ave San Juan PR 907', :US).hash.nil?
    assert !NYAddressor::Addressor.new('Carretera Estatal 115, Km. 26.9 Bo. Tablonal AGUADA PR 00602', :US).hash.nil?
  end

  def test_canadian_zip
    zip = 'H0H 0H0'
    zip_no_space = zip.delete(' ')
    base_address = '1500 Pennsylvania Ave, Washington, ON '

    addr = NYAddressor::Addressor.new(base_address + zip, :CA)
    assert_equal(
      zip_no_space.downcase,
      addr.parser.get_field(@fields::POSTAL).text
    )

    assert_equal(
      addr,
      NYAddressor::Addressor.new(base_address + zip_no_space, :CA)
    )
  end

  def test_canadian_hiway
    assert_equal(
      NYAddressor::Addressor.new('2070 BC-3, Cawston, BC V0X 1C2', :CA).sns,
      '2070bc3bc'
    )
  end

  def test_united_kingdom
    assert !NYAddressor::Addressor.new('234 West George Street (West Campbell Street), Glasgow, Glasgow City, Scotland G2 4QY, United Kingdom', :UK).hash.nil?
  end

  def test_region_detection
    assert_equal NYAddressor::detect_region("123 Penn Ave, Washington, DC, 20500"), :US
    assert_equal NYAddressor::detect_region("123 Penn Ave, Montreal, QC, H2Y 2R2"), :CA
    assert_equal NYAddressor::detect_region("123 Penn Ave, London, England SW1A 2AA"), :UK
    assert_equal NYAddressor::detect_region("123 Penn Ave, Sydney, NSW, 2000"), :AU
  end

  def test_german_address
    assert_equal(
      NYAddressor::Addressor.new('Schillerstr. 20-40, 52064 Aachen', :DE).sns,
      '2040schillerstraachen'
    )
  end
end
