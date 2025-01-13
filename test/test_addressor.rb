require 'minitest/autorun'
require 'byebug'
require_relative '../lib/ny-addressor'
require_relative '../lib/ny-addressor/utils'

class TestAddressor < Minitest::Test
  def test_perfect_match
    adr1 = NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC 20500')
    adr2 = NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC 20500')
    assert_equal adr1.compare(adr2), 1
  end

  def test_great_match
    adr1 = NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC 20500')
    adr2 = NYAddressor::Addressor.new('1600 Pennsylvania Ave, Washington, DC 20500')
    assert_in_delta 0.8, adr1.compare(adr2), 0.1
  end

  def test_okay_match
    adr1 = NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC 20500')
    adr2 = NYAddressor::Addressor.new('1500 Penn Ave, Washington, DC 20500')
    assert_in_delta 0.7, adr1.compare(adr2), 0.2
  end

  def test_bad_match
    adr1 = NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC 20500')
    adr2 = NYAddressor::Addressor.new('1530 Long Ave, Washington, DC 20500')
    assert_in_delta 0.3, adr1.compare(adr2), 0.4
  end

  def test_no_match
    adr1 = NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC 20500')
    adr2 = NYAddressor::Addressor.new('1527 Park Ave, City, MN 20499')
    assert_in_delta 0.1, adr1.compare(adr2), 0.2
  end

  def test_error_match
    adr1 = NYAddressor::Addressor.new('1600 Penn Ave, Washington, DC 20500')
    adr2 = NYAddressor::Addressor.new('12309847123047128034708')
    assert_in_delta 0.1, adr1.compare(adr2), 0.1
  end

  def test_perfect_name_inclusion
    assert_equal NYAddressor::string_inclusion('THE TAVERN BAR', 'The Tavernbar', numeric_failure: true), 1
  end

  def test_empty_string_inclusion
    assert_equal NYAddressor::string_inclusion('Tavernbar', ''), 0
  end

  def test_imperfect_name_inclusion
    assert_in_delta NYAddressor::string_inclusion('THE TAVERN BEAR', 'The Tavernbar', numeric_failure: true), 0.8, 0.1
    assert_in_delta NYAddressor::string_inclusion('THE TAVERN BEAR', 'The Tavernbar on 1st Ave', numeric_failure: true), 0.7, 0.1
    assert_in_delta NYAddressor::string_inclusion('THE TAVORN BAR', 'The Tavernbar', numeric_failure: true), 0.5, 0.2
  end

  def test_no_name_inclusion
    assert_equal NYAddressor::string_inclusion('Zoo', 'The Tavernbar', numeric_failure: true), 0
  end
end
