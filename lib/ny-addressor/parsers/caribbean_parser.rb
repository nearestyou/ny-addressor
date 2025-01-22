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

      def confirm_options
        confirm_postal
        confirm_country
        confirm_state
        confirm_street_number
        confirm_street_label
        confirm_street_direction
        confirm_street_name
        confirm_unit
        confirm_city
      end

      # United States -> usa
      def remove_united_states
        NYAddressor::constants(:US, :COUNTRY_IDENTIFIERS).each do |full_string, abbreviation|
          @normalized.gsub!(/\b#{full_string}\b/i, abbreviation)
        end
      end

      def state_pattern? part
        states = NYAddressor::constants(@region, :STATES).values
        state_words = states.map { |state| state.split(' ') }.flatten
        state_words.include? part.text
      end

      def postal_pattern? part
        part.text.has_digits?
      end

      def country_pattern? part
        NYAddressor::constants(:US, :COUNTRY_IDENTIFIERS).values.include? part.text
      end

      def confirm_state
        parts = potential(AddressField::STATE)
        consecutive(parts.reverse).each { |part| part.confirm(AddressField::STATE) }
      end
    end
  end
end
