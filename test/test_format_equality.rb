require 'minitest/autorun'
require_relative '../lib/ny-addressor/parsers/generic_parser'
require_relative '../lib/ny-addressor'
require 'byebug'

class TestFormatEquality < Minitest::Test
  def test_simple_equality
    str = '1600 Penn Ave, Washington, DC, 20500'
    assert_equal NYAddressor::Addressor.new(str, :US), NYAddressor::Addressor.new(str, :US)
  end
end
