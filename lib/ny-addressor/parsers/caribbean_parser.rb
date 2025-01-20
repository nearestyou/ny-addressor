# frozen_string_literal: true
require_relative 'generic_parser'

# 128 Middle Road, Warwick, Bermuda WK04, United States

module NYAddressor
  module Parsers
    class CaribbeanParser < GenericParser
      def initialize(address, region)
        @raw_input = address.downcase
        @region = region
        # must unrepeat first, otherwise new york, NY will be overwritten
        @normalized = NYAddressor::normalize(@raw_input.unrepeat, @region).clean
        remove_united_states
        split # sets @parts
        set_options
      end

      # United States -> usa
      def remove_united_states
        NYAddressor::constants(:US, :COUNTRY_IDENTIFIERS).each do |full_string, abbreviation|
          @normalized.gsub!(/\b#{full_string}\b/i, abbreviation)
        end
      end

      def postal_pattern? part
        part.text.has_digits?
      end

      def country_pattern? part
        NYAddressor::constants(:US, :COUNTRY_IDENTIFIERS).values.include? part.text
      end
    end
  end
end
