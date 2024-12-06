require 'minitest/autorun'
require_relative '../lib/ny-addressor'

class TestNormalization < Minitest::Test
  def test_random
    assert_equal NYAddressor::normalize("North Dakota", :US), 'nd'
  end
end
