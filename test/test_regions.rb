require 'minitest/autorun'
require_relative '../lib/ny-addressor'
require 'byebug'

class TestRegions < Minitest::Test
  def test_wisconsin_addresses
    assert NYAddressor::Addressor.new('W204N11912 Goldendale Rd,AURORA,OR,97002').sns == 'w204n11912goldendaleor'
    assert NYAddressor::Addressor.new('W204 N11912 Goldendale Rd,AURORA,OR,97002').sns == 'w204n11912goldendaleor'
  end

  def test_puero_rican
    assert !NYAddressor::Addressor.new('1310 Ashford Ave San Juan PR 907', :US).hash.nil?
    assert !NYAddressor::Addressor.new('Carretera Estatal 115, Km. 26.9 Bo. Tablonal AGUADA PR 00602', :US).hash.nil?
  end

  def test_canadian_zip
    zip = 'H0H 0H0'
    zip_no_space = zip.delete(' ')
    base_address = '1500 Pennsylvania Ave, Washington, ON '
    assert_equal(
      NYAddressor::Addressor.new(base_address + zip, :CA),
      NYAddressor::Addressor.new(base_address + zip_no_space, :CA)
    )
  end

  def test_canadian_hiway
    assert_equal(
      NYAddressor.new('2070 BC-3, Cawston, BC V0X 1C2', :CA).sns,
      '2070bc3bc'
    )
  end

  def test_united_kingdom
    assert !NYAddressor::Addressor.new('234 West George Street (West Campbell Street), Glasgow, Glasgow City, Scotland G2 4QY, United Kingdom', :UK).hash.nil?
  end

end
