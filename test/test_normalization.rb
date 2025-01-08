require 'minitest/autorun'
require_relative '../lib/ny-addressor'

class TestNormalization < Minitest::Test
  def test_random
    assert_equal NYAddressor::normalize("North Dakota", :US), 'nd'
  end

  def test_missing
    assert NYAddressor::Addressor.new(nil).hash.nil?
  end

  def test_remove_cross_street
    assert_equal(
      '1505',
      '1505'.extend(NYAddressor::AddressHelper).remove_cross_street
    )

    assert_equal(
      '1505',
      '1505 & 1510'.extend(NYAddressor::AddressHelper).remove_cross_street
    )

    assert_equal(
      '1505 Penn Ave',
      '1505 & 1510 Penn Ave'.extend(NYAddressor::AddressHelper).remove_cross_street
    )
  end
end
