require 'minitest/autorun'
require_relative '../lib/ny-addressor'

class TestNormalization < Minitest::Test
  def test_random
    assert_equal NYAddressor::normalize("North Dakota", :US), 'nd'
  end

  def test_missing
    assert NYAddressor::Addressor.new(nil).hash.nil?
  end
end
