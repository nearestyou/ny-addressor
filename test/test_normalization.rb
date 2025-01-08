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

  def test_unit_formats
    assert_equal(
      '1600 Penn Ave',
      '1600 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    assert_equal(
      '#A 1600 Penn Ave',
      '1600A Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    assert_equal(
      '#A 1600 Penn Ave',
      '1600-A Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    assert_equal(
      '#A1 1600 Penn Ave',
      '1600-A1 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    assert_equal(
      '#A 1600 Penn Ave',
      'A-1600 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    assert_equal(
      '#A1 1600 Penn Ave',
      'A1-1600 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    assert_equal(
      '#A 1600 Penn Ave',
      'A - 1600 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    assert_equal(
      '#A1 1600 Penn Ave',
      'A1 - 1600 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    )

    # assert_equal(
    #   '#1 1600 Penn Ave',
    #   '1-1600 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    # )

    # assert_equal(
    #   '#1 1600 Penn Ave',
    #   '1 - 1600 Penn Ave'.extend(NYAddressor::AddressHelper).separate_unit
    # )
  end #test_unit_formats
end
