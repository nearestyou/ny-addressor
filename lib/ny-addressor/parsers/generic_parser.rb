# frozen_string_literal: true
require_relative '../address_part'
require_relative '../../extensions/string'
require_relative '../constants'
require 'byebug'

module NYAddressor
  module Parsers
    class GenericParser
      attr_accessor :parts
      def initialize(address, region)
        @original = address.downcase
        @region = region

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

      private

      def set_pattern_options
        @parts.flatten.each do |part|
          part.determine_pattern(:street_number, method(:street_number_pattern?))
          part.determine_pattern(:street_name, method(:street_name_pattern?))
          part.determine_pattern(:street_label, method(:street_label_pattern?))
          part.determine_pattern(:street_direction, method(:street_direction_pattern?))
          part.determine_pattern(:unit, method(:unit_pattern?))
          part.determine_pattern(:city, method(:city_pattern?))
        end
      end

      # Checks if an address part matches the pattern for a street number
      # @param part [AddressPart] to evaluate
      # @return [Boolean] does the part follow a street number pattern?
      def street_number_pattern? part
        return false if NYAddressor::constants(@region, :UNIT_DESCRIPTORS).include? part.text
        return true if part.text.has_digits?
        false
      end

      def street_name_pattern? part
        return false if NYAddressor::constants(@region, :UNIT_DESCRIPTORS).include? part.text
        return false if part.text.numeric?
        true
      end

      def street_label_pattern? part
        NYAddressor::constants(@region, :LABEL_DESCRIPTORS).include? part.text.standardize
      end

      def street_direction_pattern? part
        NYAddressor::constants(@region, :DIRECTION_DESCRIPTORS).include? part.text.standardize
      end

      def unit_pattern? part
        return true if NYAddressor::constants(@region, :UNIT_DESCRIPTORS).include? part.text
        return true if part.text.has_digits?
        false
      end

      def city_pattern? part
        return true if part.text.alphabetic?
        return true if part.text == 'st.' # saint
        false
      end
    end
  end
end
