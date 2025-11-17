# frozen_string_literal: true
require "countries"
module NYAddressor
  module Canonicalizer
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

    def apply(parts)
      parts[:country] = normalize_country(parts[:country]) if parts[:country]
      parts[:state] = normalize_state(parts[:state]) if parts[:state]
      parts[:postcode] = normalize_postcode(parts[:postcode]) if parts[:postcode]

      parts[:city] = strip_state_from_city(parts[:city], parts[:state]) if parts[:city] && parts[:state]

      parts
    end
  end
end
