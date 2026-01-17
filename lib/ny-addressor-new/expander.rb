# frozen_string_literal: true
module NYAddressorNEW
  module Expander
    module_function

    # Make commas safe for libpostal
    def normalize_commas(raw)
      raw.to_s
        .gsub(/,(\S)/, ', \1')  # add space after commas
        .gsub(/\s+/, ' ')       # collapse crazy whitespace
        .strip
    end

    # @param raw [String]
    # @param opts [Hash] override defaults
    # @return [Array<String>]
    def expand(raw, opts = {})
      # options = DEFAULTS.merge(opts || {})
      # Postal::Expand.expand_address(raw.to_s, **options) || []
      Postal::Expand.expand_address(normalize_commas(raw)) || []
    end

    # @param raw [String]
    # @param opts [Hash]
    # @yield [variants] an expanded address
    # @return [String]
    def normalize(raw, opts = {}, &selector)
      variants = expand(raw, opts).uniq
      return "" if variants.empty?

      (selector || method(:best_variant_by_heuristic)).call(variants)
      # yield(variants)
    end

    def best_variant_by_heuristic(variants)
      scored = variants.map do |v|
        parts = Parser.parts(v)

        score = 0
        score += 20 if parts[:house_number]
        score += 15 if parts[:street_name]
        score += 1 if parts[:street_label]

        score += 5 if parts[:city]
        score += 3 if parts[:state]
        score += 2 if parts[:postcode]

        score -= 10 if parts[:street_name] == "saint"

        [score, v]
      end

      scored.max_by { |score, v| [score, -v.length, v] }.last
    end
  end
end
