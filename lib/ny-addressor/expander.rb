# frozen_string_literal: true
module NYAddressor
  class Expander

    # @param raw [String]
    # @param opts [Hash] override defaults
    # @return [Array<String>]
    def self.expand(raw, opts = {})
      # options = DEFAULTS.merge(opts || {})
      # Postal::Expand.expand_address(raw.to_s, **options) || []
      Postal::Expand.expand_address(raw.to_s) || []
    end

    # @param raw [String]
    # @param opts [Hash]
    # @yield [variants] optional block to pick custom variant
    # @return [String]
    def self.normalize(raw, opts = {}, &canonicalizer)
      variants = expand(raw, opts).uniq
      return "" if variants.empty?
      canonicalizer ? canonicalizer.call(variants) : variants.min_by { |v| [v.length, v] }
    end
  end
end
