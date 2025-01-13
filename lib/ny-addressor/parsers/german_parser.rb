# frozen_string_literal: true
require_relative 'generic_parser'
require_relative '../address_part'
require_relative '../address_field'

# Schillerstr. 20-40, 52064 Aachen
# Name: Schillerstr
# Number: 20-40
# Postal: 52064
# State: Aachen

module NYAddressor
  module Parsers
    class GermanParser < GenericParser
      def position_options part
        f = AddressField
        num_parts = @parts.flatten.size
        case part.position
        when 0
          [f::STREET_NAME]
        when 1
          [f::STREET_NUMBER]
        when num_parts - 4
          [f::UNIT]
        when num_parts - 3
          [f::UNIT, f::POSTAL]
        when num_parts - 2
          [f::POSTAL, f::STATE]
        when num_parts - 1
          [f::STATE, f::COUNTRY]
        else
          [f::STREET_NUMBER, f::STREET_NAME, f::UNIT, f::STATE, f::POSTAL, f::COUNTRY]
        end
      end

      def comma_position_options part
        f = AddressField
        [f::STREET_NUMBER, f::STREET_NAME, f::UNIT, f::STATE, f::POSTAL, f::COUNTRY]
      end

      def set_pattern_options
        @parts.flatten.each do |part|
          part.determine_pattern(AddressField::STREET_NUMBER, method(:street_number_pattern?))
          part.determine_pattern(AddressField::STREET_NAME, method(:street_name_pattern?))
          part.determine_pattern(AddressField::UNIT, method(:unit_pattern?))
          part.determine_pattern(AddressField::STATE, method(:state_pattern?))
          part.determine_pattern(AddressField::POSTAL, method(:postal_pattern?))
          part.determine_pattern(AddressField::COUNTRY, method(:country_pattern?))
        end
      end

      def state_pattern? part
        part.text.has_letters?
      end

      def confirm_options
        confirm_postal
        confirm_country
        confirm_street_number
        confirm_state
        confirm_street_name
        confirm_unit
      end

      def confirm_country
        known_after = [AddressField::POSTAL]
        parts = potential_between(AddressField::COUNTRY, known_after)
        parts&.last&.confirm(AddressField::COUNTRY)
      end

      def confirm_state
        known_after = [AddressField::POSTAL]
        known_before = [AddressField::COUNTRY]
        potential_between(AddressField::STATE, known_after, known_before)&.last&.confirm(AddressField::STATE)
      end

      def confirm_street_name
        known_before = [AddressField::STREET_NUMBER]
        potential_between(AddressField::STREET_NAME, [], known_before)&.last&.confirm(AddressField::STREET_NAME)
      end

      def confirm_unit
        known_after = [AddressField::STREET_NUMBER]
        known_before = [AddressField::POSTAL]
        potential_between(AddressField::UNIT, known_after, known_before)&.last&.confirm(AddressField::UNIT)
      end
    end
  end
end
