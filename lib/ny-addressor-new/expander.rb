# frozen_string_literal: true
module NYAddressorNEW
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
    # @yield [variants] an expanded address
    # @return [String]
    def self.normalize(raw, opts = {}, &selector)
      variants = expand(raw, opts).uniq
      return "" if variants.empty?

      yield(variants)
    end

    def self.best_variant_by_heuristic(variants)
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
