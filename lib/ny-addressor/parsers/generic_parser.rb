# frozen_string_literal: true
require_relative '../address_part'
require_relative '../../extensions/string'
require_relative '../constants'
require 'byebug'

module NYAddressor
  module Parsers
    class GenericParser
      attr_accessor :parts
      def initialize(address)
        @original = address.downcase

        full_position = -1
        # Splits the address into comma-separated groups
        # @return [Array<Array<AddressPart>>] An array of address part arrays,
        # separated by comma groups
        @parts = @original.split(',').map.with_index do |group, group_index|
          group.clean.unrepeat.split(' ').map.with_index do |word, group_position|
            full_position += 1
            AddressPart.new(word, full_position, group_index, group_position)
          end
        end
        set_pattern_options
      end

      def set_pattern_options
        @parts.flatten.each do |part|
          part.determine_pattern(:street_number, method(:street_number_pattern?))
        end
      end

      private

      # Checks if an address part matches the pattern for a street number
      # @param part [AddressPart] to evaluate
      # @return [Boolean] does the part follow a street number pattern?
      def street_number_pattern? part
        return false if Constants::Generics::UNIT_DESCRIPTORS.include? part.text
        return true if part.text.has_digits?
        false
      end
    end
  end
end
