# frozen_string_literal: true
require "ruby_postal/expand"
require "ruby_postal/parser"

require_relative "ny-addressor/version"
require_relative "ny-addressor/result"
require_relative "ny-addressor/expander"
require_relative "ny-addressor/parser"
require_relative "ny-addressor/fingerprinter"
require_relative "ny-addressor/canonicalizer"
require_relative "ny-addressor/selectors"

module NYAddressor
  # @param raw [String] the address text
  # @param expand_opts [Hash] options passed to libpostal expand
  # @param selector [Proc,nil] optional block to choose an expansion
  # @return [NYAddressor::Result]
  def self.process(raw, expand_opts: {}, selector: nil)
    selector ||= Selectors::HEURISTIC
    Result.new(raw, expand_opts: expand_opts, selector: selector)
  end

  # @see NYAddressor::Result#normalized
  def self.normalize(raw, **k) = process(raw, **k).normalized

  # @see NYAddressor::Result#parts
  def self.parts(raw, **k) = process(raw, **k).parts

  # @see NYAddressor::Result#fingerprints
  def self.fingerprints(raw, **k) = process(raw, **k).fingerprints
end
