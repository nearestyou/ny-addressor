# frozen_string_literal: true
require_relative 'generic_parser'
# 21 Rue du Mesnil, 50400 Granville, FR

module NYAddressor
  module Parsers
    class FrenchParser < GenericParser
      def confirm_options
        confirm_postal
        confirm_country
        confirm_street_number
        confirm_state
        confirm_street_name
        confirm_unit
      end

      def state_pattern? part
        part.text.has_letters?
      end

      def confirm_state
        known_after = [AddressField::POSTAL]
        known_before = [AddressField::COUNTRY]
        parts = potential_between(AddressField::STATE, known_after, known_before)
        consecutive(parts).each { |part| part.confirm(AddressField::STATE) }
      end
    end
  end
end
