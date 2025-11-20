# frozen_string_literal: true
require "countries"
module NYAddressor
  module Canonicalizer
    TRAILING_ALPHA_UNIT_RE  = /\A(\d+)[-\s]*([a-z][0-9a-z]*)\z/i  # 16A, 16-A, 16 A -> house_number: 16, unit: A
    LEADING_ALPHA_UNIT_RE   = /\A([a-z][0-9a-z]*)[-\s]+(\d+)\z/i
    LEADING_NUMERIC_UNIT_RE = /\A(\d+)[-\s]+(\d+)\z/              # 70-15355 -> house_number: 15355, unit: 70

    STATES = {
      "district of columbia" => "dc"
    }.freeze

    module_function

    def normalize_country(string)
      country = ISO3166::Country.find_country_by_any_name(string) ||
                ISO3166::Country.find_country_by_alpha2(string) ||
                ISO3166::Country.find_country_by_alpha3(string)
      (country&.alpha2 || string).downcase
    end

    def normalize_state(string)
      return STATES[string] || string
    end

    def normalize_postcode(string)
      string[..4]
    end

    def normalize_unit(string)
      tokens = string.split(/\s+/)

      # Look for a number
      unit = tokens.find { |t| t =~ /\d/ }
      return string if unit.nil?

      unit = unit
        .sub(/\A[^0-9a-z]+/, "")  # strip #, no., etc
        .gsub(/[^0-9a-z\-]/, "")  # strip interior punctuation

      unit
    end

    # minneapolis mn, mn -> minneapolis, mn
    def strip_state_from_city(city, state)
      tokens = city.split(/\s+/)
      return city if tokens.size < 2

      if tokens.last == state
        tokens[0..-2].join(" ")
      else
        city
      end
    end

    def strip_cross_street(string)
      # remove "at <number>"
      # penn at 16th -> penn
      n = string.sub(/
                      \b at           # look for "at" after word
                      \s+\d+          # whitespace & number
                      (st|nd|rd|th)?  # optional ordinal
                      \b
                     /x, "").strip

      # remove &
      # 1505&1507 -> 1505
      n = n.sub(/
                \A(?:&|and)          # match & || "and" at start of string
                \s*\d+\s+            # whitespace, number, whitespace
                /x, "").strip

      n.strip
    end

    def extract_unit_from_house_number!(parts)
      hn = parts[:house_number].to_s.strip

      if hn =~ TRAILING_ALPHA_UNIT_RE
        base = Regexp.last_match(1)
        suf  = Regexp.last_match(2).downcase
        parts[:unit] ||= suf
        parts[:house_number] = base
      end

      if hn =~ LEADING_ALPHA_UNIT_RE
        pre  = Regexp.last_match(1)
        base = Regexp.last_match(2)

        parts[:unit] ||= pre
        parts[:house_number] = base
      end

      if hn =~ LEADING_NUMERIC_UNIT_RE
          first  = Regexp.last_match(1)
          second = Regexp.last_match(2)
          if second.to_i > first.to_i
            parts[:unit] ||= first
            parts[:house_number] = second
          end
      end

      parts
    end

    # street_name: penn 7, unit: nil => street_name: penn, unit: 7
    def extract_trailing_unit_from_street!(parts)
      return parts if parts[:unit].to_s.strip != ""
      return parts unless parts[:street_name]
      return parts unless parts[:street_label]

      tokens = parts[:street_name].split(/\s+/)
      return parts if tokens.size < 2

      last = tokens.last
      return parts unless last =~ /\A[0-9][0-9a-z\-]*\z/i

      parts[:unit] = last
      parts[:street_name] = tokens[0..-2].join(" ")
      parts
    end

    def apply(parts)
      parts[:country] = normalize_country(parts[:country]) if parts[:country]
      parts[:state] = normalize_state(parts[:state]) if parts[:state]
      parts[:postcode] = normalize_postcode(parts[:postcode]) if parts[:postcode]

      parts[:street_name] = strip_cross_street(parts[:street_name]) if parts[:street_name]
      parts[:city] = strip_state_from_city(parts[:city], parts[:state]) if parts[:city] && parts[:state]

      parts = extract_unit_from_house_number!(parts)
      parts = extract_trailing_unit_from_street!(parts)
      parts[:unit] = normalize_unit(parts[:unit]) if parts[:unit]

      parts
    end
  end
end
