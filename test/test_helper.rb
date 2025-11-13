# frozen_string_literal: true
require "minitest/autorun"
require "pp" # pretty inspect
require "byebug"
require_relative "../lib/ny-addressor"

module TestHelpers
  def result(addr) = NYAddressor::Result.new(addr)
  def fingerprints(addr) = result(addr).fingerprints

  def debug_dump(addr, expansions: 6)
    r = result(addr)
    <<~TXT
    -- Address: #{addr.inspect}
    expanded_variants:
    #{r.expanded_variants.take(expansions).map { |v| " - #{v}" }.join("\n")}

    parts:
    #{r.parts.pretty_inspect.strip}
    TXT
  end

  def assert_with_diag(msg_prefix, a, b)
    yield
  rescue Minitest::Assertion => e
    diag = <<~MSG
    #{msg_prefix}
    #{result(a).normalized.inspect}
    #{result(b).normalized.inspect}
      === A ===
    #{debug_dump(a)}

      === B ===
    #{debug_dump(b)}
    MSG
    raise Minitest::Assertion, "#{e.message}#{diag}"
  end

  def assert_same_full(a, b, msg=nil)
    assert_with_diag("FULL fingerprint mismatch", a, b) do
      assert_equal(fingerprints(a)[:full], fingerprints(b)[:full], msg)
    end
  end

  def refute_same_full(a, b, msg=nil)
    assert_with_diag("FULL fingerprint unexpectedly matched", a, b) do
      refute_equal(fingerprints(a)[:full], fingerprints(b)[:full], msg)
    end
  end

  def assert_same_zipless(a, b, msg=nil)
    assert_with_diag("zipless fingerprint mismatch", a, b) do
      assert_equal(fingerprints(a)[:zipless], fingerprints(b)[:zipless], msg)
    end
  end

  def assert_same_countryless(a, b, msg=nil)
    assert_with_diag("countryless fingerprint mismatch", a, b) do
      assert_equal(fingerprints(a)[:countryless], fingerprints(b)[:countryless], msg)
    end
  end

  def assert_same_unitless(a, b, msg=nil)
    assert_with_diag("unitless fingerprint mismatch", a, b) do
      assert_equal(fingerprints(a)[:unitless], fingerprints(b)[:unitless], msg)
    end
  end

  def assert_same_sns(a, b, msg=nil)
    assert_with_diag("SNS fingerprint mismatch", a, b) do
      assert_equal(fingerprints(a)[:sns], fingerprints(b)[:sns], msg)
    end
  end
end

class Minitest::Test
  include TestHelpers
end
