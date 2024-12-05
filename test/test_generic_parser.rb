require 'minitest/autorun'
require_relative '../lib/ny-addressor/parsers/generic_parser'
require 'byebug'

class TestGenericParser < Minitest::Test
  def setup
    @address = "123 Main St N, Springfield, IL 62704, USA"
    @parser = NYAddressor::Parsers::GenericParser.new(@address, :US)
  end

  def test_address_split
    assert_equal 4, @parser.parts.size, "Expected 4 comma groups"
    assert_equal 8, @parser.parts.flatten.size, "Expected 7 individual parts"
  end

  def test_part_positions
    part = @parser.parts[0][0]
    assert_equal 0, part.position
    assert_equal 0, part.group
    assert_equal 0, part.group_position

    part = @parser.parts[3][0]
    assert_equal 7, part.position, "Expected to be 6th part"
    assert_equal 3, part.group, "Expected to be in the 3rd comma group"
    assert_equal 0, part.group_position, "Expected first in comma group"
    assert_equal 'usa', part.text
  end

  def test_street_number_pattern
    assert @parser.parts[0][0].from_pattern.include?(:street_number)
  end

  def test_street_name_pattern
    assert @parser.parts[0][1].from_pattern.include?(:street_name)
    assert !@parser.parts[0][0].from_pattern.include?(:street_name)
  end

  def test_direction_pattern
    assert @parser.parts[0][3].from_pattern.include?(:street_direction)
  end

  def test_unit_pattern
    assert @parser.parts[0][0].from_pattern.include?(:unit)
  end
end
