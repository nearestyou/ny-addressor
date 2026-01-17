# frozen_string_literal: true

module NYAddressorNEW
  class Result
    attr_reader :raw

    # @param raw [String] address
    # @param expand_opts [Hash] options passed to libpostal expand
    # @param selector [Proc] selector for expand variant
    def initialize(raw, expand_opts: {}, selector: Selectors::HEURISTIC)
      @raw = raw.to_s
      @expand_opts = expand_opts || {}
      @selector = selector
      @__normalized = @__parts = @__fingerprints = @__variants = nil
    end

    # @return [String]
    def normalized
      @__normalized ||= Expander.normalize(@raw, @expand_opts, &@selector)
    end

    # @return [Hash{Symbol=>String}]
    def parts
      @__parts ||= begin
                     Canonicalizer.apply(Parser.parts(normalized))
                   end
    end

    # @return [Hash{Symbol=>String}]
    def fingerprints
      @__fingerprints ||= Fingerprinter.all(parts)
    end

    # @return [Array<String>]
    def expanded_variants
      @__variants ||= Expander.expand(@raw, @expand_opts).uniq
    end

    # @return [Hash]
    def to_h
      { normalized: normalized, parts: parts, fingerprints: fingerprints }
    end
  end
end
