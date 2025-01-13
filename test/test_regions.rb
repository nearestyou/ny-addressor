require 'minitest/autorun'
require_relative '../lib/ny-addressor'
require 'byebug'

class TestRegions < Minitest::Test
  def setup
    @fields = NYAddressor::AddressField
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
    assert_equal NYAddressor::Addressor.detect_region("123 Penn Ave, Washington, DC, 20500"), :US
    assert_equal NYAddressor::Addressor.detect_region("123 Penn Ave, Montreal, QC, H2Y 2R2"), :CA
    assert_equal NYAddressor::Addressor.detect_region("123 Penn Ave, London, England SW1A 2AA"), :UK
    assert_equal NYAddressor::Addressor.detect_region("123 Penn Ave, Sydney, NSW, 2000"), :AU
  end

  def test_german_address
    assert_equal(
      NYAddressor::Addressor.new('Schillerstr. 20-40, 52064 Aachen', :DE).sns,
      '2040schillerstraachen'
    )
  end
end
