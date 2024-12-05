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
        set_options
      end

      # @param sym [Symbol] which field to look for (ex :street_name)
      # @return [Array[AddressPart]]
      def potential(sym)
        @parts.flatten.select do |part|
          part.confirmed.nil? && part.from_all.include?(sym)
        end
      end

      # @param sym [Symbol] which field to get
      # @return [AddressPart, nil]
      def get_field(sym)
        @parts.flatten.find { |part| part.confirmed == sym }
      end

      private

      def set_options
        @parts.flatten.each {|part| part.determine_position(method(:position_options)) }
        @parts.flatten.each {|part| part.determine_comma_position(method(:comma_position_options)) }
        set_pattern_options
        @parts.flatten.each {|part| part.consolidate_options }
      end

      def position_options part
        num_parts = @parts.flatten.size
        case part.position
        when 0
          %i[street_number street_name unit]
        when 1
          %i[street_number street_name street_direction street_label unit]
        when 2
          %i[street_number street_name street_label unit street_direction]
        when 3
          %i[street_name street_label unit street_direction city state]
        when num_parts - 4
          %i[city state street_direction street_label unit postal]
        when num_parts - 3
          %i[city state postal]
        when num_parts - 2
          %i[city state postal country]
        when num_parts - 1
          %i[state postal country]
        else
          %i[default street_number street_name street_label street_direction unit city state postal country]
        end
      end

      # Hypothesize what this part could mean based off which comma group it's in
      def comma_position_options part
        first = %i[street_number street_name street_direction street_label unit]
        group_sizes = {
          3 => [
            first,
            %i[unit city state postal],
            %i[city state postal country]
          ],
          4 => [
            first,
            %i[unit city state],
            %i[city state postal],
            %i[state postal country]
          ],
          5 => [
            first,
            %i[unit city],
            %i[city state],
            %i[state postal],
            %i[postal country]
          ],
          6 => [
            first,
            %i[unit],
            %i[city],
            %i[state],
            %i[postal],
            %i[country],
          ]
        }
        group_sizes[@parts.size] ? group_sizes[@parts.size][part.group] : %i[street_number street_name street_direction street_label unit city state postal country default]
      end

      def set_pattern_options
        @parts.flatten.each do |part|
          part.determine_pattern(:street_number, method(:street_number_pattern?))
          part.determine_pattern(:street_name, method(:street_name_pattern?))
          part.determine_pattern(:street_label, method(:street_label_pattern?))
          part.determine_pattern(:street_direction, method(:street_direction_pattern?))
          part.determine_pattern(:unit, method(:unit_pattern?))
          part.determine_pattern(:city, method(:city_pattern?))
          part.determine_pattern(:state, method(:state_pattern?))
          part.determine_pattern(:postal, method(:postal_pattern?))
          part.determine_pattern(:country, method(:country_pattern?))
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

      def state_pattern? part
        NYAddressor::constants(@region, :STATE_DESCRIPTORS).include? part.text
      end

      def postal_pattern? part
        format = NYAddressor::constants(@region, :POSTAL_FORMATS)
        !!(part.text =~ format)
      end

      def country_pattern? part
        NYAddressor::constants(@region, :COUNTRY_DESCRIPTORS).include? part.text
      end
    end
  end
end
