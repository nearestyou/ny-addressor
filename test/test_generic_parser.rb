require 'minitest/autorun'
require_relative '../lib/ny-addressor/parsers/generic_parser'
require 'byebug'

class TestGenericParser < Minitest::Test
  def setup
    @address = "123 Main St, Springfield, IL 62704, USA"
    @parser = NYAddressor::Parsers::GenericParser.new(@address)
  end

  def test_address_split
    assert_equal 4, @parser.parts.size
    assert_equal 7, @parser.parts.flatten.size
  end

  def test_part_positions
    part = @parser.parts[0][0]
    assert_equal 0, part.position
    assert_equal 0, part.group
    assert_equal 0, part.group_position

    part = @parser.parts[3][0]
    assert_equal 6, part.position
    assert_equal 3, part.group
    assert_equal 0, part.group_position
    assert_equal 'usa', part.text
  end
end
