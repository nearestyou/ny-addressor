# frozen_string_literal: true
require "ruby_postal/expand"
require "ruby_postal/parser"

require_relative "ny-addressor-new/version"
require_relative "ny-addressor-new/result"
require_relative "ny-addressor-new/expander"
require_relative "ny-addressor-new/parser"
require_relative "ny-addressor-new/fingerprinter"

module NYAddressorNEW
  # @param raw [String] the address text
  # @param expand_opts [Hash] options passed to libpostal expand
  # @param canonicalizer [Proc,nil] optional block to choose an expansion
  # @return [NYAddressor::Result]
  def self.process(raw, expand_opts: {}, canonicalizer: nil)
    Result.new(raw, expand_opts: expand_opts, canonicalizer: canonicalizer)
  end

  # @see NYAddressor::Result#normalized
  def self.normalize(raw, **k) = process(raw, **k).normalized

  # @see NYAddressor::Result#parts
  def self.parts(raw, **k) = process(raw, **k).parts

  # @see NYAddressor::Result#fingerprints
  def self.fingerprints(raw, **k) = process(raw, **k).fingerprints
end
