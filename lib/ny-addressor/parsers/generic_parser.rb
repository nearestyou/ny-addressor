# frozen_string_literal: true
require_relative '../address_part'
require_relative '../../extensions/string'
require_relative '../constants'
require_relative '../address_field'
require 'byebug'

module NYAddressor
  module Parsers
    class GenericParser
      attr_reader :parts
      def initialize(address, region)
        @raw_input = address.downcase
        @region = region
        @normalized = NYAddressor::normalize(@raw_input, @region).clean.unrepeat

        full_position = -1
        # Splits the address into comma-separated groups
        # @return [Array<Array<AddressPart>>] An array of address part arrays,
        # separated by comma groups
        @parts = @normalized.split(',').map.with_index do |group, group_index|
          group.split(' ').map.with_index do |word, group_position|
            full_position += 1
            AddressPart.new(word, full_position, group_index, group_position)
          end
        end
        set_options
      end

      # @param field [AddressField] which field to look for (ex :street_name)
      # @return [Array<AddressPart>]
      def potential(field)
        @parts.flatten.select do |part|
          part.confirmed.nil? && part.from_all.include?(field)
        end
      end

      # @param field [AddressField] which field to look for
      # @param after [Array<AddressField>] result comes after these fields
      # @param before [Array<AddressField>] result comes before these fields
      # @return [Array<AddressField>]
      def potential_between(field, after=[], before=[])
        min = last_instance_of(after)
        max = first_instance_of(before)
        potential(field).select { |part| part.position > min && part.position < max }
      end

      # @param field [AddressField] which `confirmed` field to get
      # @return [AddressPart, nil]
      def get_field(field)
        @parts.flatten.find { |part| part.confirmed == field }
      end

      # @param fields [Array<AddressField>] List of address fields
      # @return [Integer] The position of the first field that matches the criteria
      def first_instance_of(fields)
        positions = fields.map { |field| get_field(field)&.position }
        [Float::INFINITY, *positions].compact.min
      end
      def last_instance_of(fields)
        positions = fields.map { |field| get_field(field)&.position }
        [-1, *positions].compact.max
      end

      private

      def set_options
        # Determine what a part likely is based off it's position
        @parts.flatten.each {|part| part.determine_position(method(:position_options)) }

        # Determine what a part likely is based off it's comma group
        @parts.flatten.each {|part| part.determine_comma_position(method(:comma_position_options)) }

        # Determine what a part likely is based off its content
        set_pattern_options

        # Combine options from different methods
        @parts.flatten.each {|part| part.consolidate_options }

        # Select parts to use
        confirm_options
      end

      def position_options part
        f = AddressField
        num_parts = @parts.flatten.size
        case part.position
        when 0
          [f::STREET_NUMBER, f::STREET_NAME, f::UNIT]
        when 1
          [f::STREET_NUMBER, f::STREET_NAME, f::STREET_DIRECTION, f::STREET_LABEL, f::UNIT]
        when 2
          [f::STREET_NUMBER, f::STREET_NAME, f::STREET_LABEL, f::UNIT, f::STREET_DIRECTION]
        when 3
          [f::STREET_NAME, f::STREET_LABEL, f::UNIT, f::STREET_DIRECTION, f::CITY, f::STATE]
        when num_parts - 4
          [f::CITY, f::STATE, f::STREET_DIRECTION, f::STREET_LABEL, f::UNIT, f::POSTAL]
        when num_parts - 3
          [f::CITY, f::STATE, f::POSTAL]
        when num_parts - 2
          [f::CITY, f::STATE, f::POSTAL, f::COUNTRY]
        when num_parts - 1
          [f::STATE, f::POSTAL, f::COUNTRY]
        else
          [f::STREET_NUMBER, f::STREET_NAME, f::STREET_LABEL, f::STREET_DIRECTION, f::UNIT, f::CITY, f::STATE, f::POSTAL, f::COUNTRY]
        end
      end

      # Hypothesize what this part could mean based off which comma group it's in
      def comma_position_options part
        f = AddressField
        first = [f::STREET_NUMBER, f::STREET_NAME, f::STREET_DIRECTION, f::STREET_LABEL, f::UNIT]
        group_sizes = {
          3 => [
            first,
            [f::UNIT, f::CITY, f::STATE, f::POSTAL],
            [f::CITY, f::STATE, f::POSTAL, f::COUNTRY]
          ],
          4 => [
            first,
            [f::UNIT, f::CITY, f::STATE],
            [f::CITY, f::STATE, f::POSTAL],
            [f::STATE, f::POSTAL, f::COUNTRY]
          ],
          5 => [
            first,
            [f::UNIT, f::CITY],
            [f::CITY, f::STATE],
            [f::STATE, f::POSTAL],
            [f::POSTAL, f::COUNTRY]
          ],
          6 => [
            first,
            [f::UNIT],
            [f::CITY],
            [f::STATE],
            [f::POSTAL],
            [f::COUNTRY],
          ]
        }
        group_sizes[@parts.size] ? group_sizes[@parts.size][part.group] : [
          f::STREET_NUMBER,
          f::STREET_NAME,
          f::STREET_DIRECTION,
          f::STREET_LABEL,
          f::UNIT,
          f::CITY,
          f::STATE,
          f::POSTAL,
          f::COUNTRY
        ]
      end

      def set_pattern_options
        @parts.flatten.each do |part|
          part.determine_pattern(AddressField::STREET_NUMBER, method(:street_number_pattern?))
          part.determine_pattern(AddressField::STREET_NAME, method(:street_name_pattern?))
          part.determine_pattern(AddressField::STREET_LABEL, method(:street_label_pattern?))
          part.determine_pattern(AddressField::STREET_DIRECTION, method(:street_direction_pattern?))
          part.determine_pattern(AddressField::UNIT, method(:unit_pattern?))
          part.determine_pattern(AddressField::CITY, method(:city_pattern?))
          part.determine_pattern(AddressField::STATE, method(:state_pattern?))
          part.determine_pattern(AddressField::POSTAL, method(:postal_pattern?))
          part.determine_pattern(AddressField::COUNTRY, method(:country_pattern?))
        end
      end

      # Checks if an address part matches the pattern for a street number
      # @param part [AddressPart] to evaluate
      # @return [Boolean] does the part follow a street number pattern?
      def street_number_pattern? part
        return false if NYAddressor::constants(@region, :UNIT_TYPES).values.include? part.text
        return true if part.text.has_digits?
        false
      end

      def street_name_pattern? part
        return false if NYAddressor::constants(@region, :UNIT_TYPES).values.include? part.text
        return false if part.text.numeric?
        true
      end

      def street_label_pattern? part
        NYAddressor::constants(@region, :STREET_LABELS).values.include? part.text.standardize
      end

      def street_direction_pattern? part
        NYAddressor::constants(@region, :STREET_DIRECTIONS).values.include? part.text.standardize
      end

      def unit_pattern? part
        return true if NYAddressor::constants(@region, :UNIT_TYPES).values.include? part.text
        return true if part.text.has_digits?
        false
      end

      def city_pattern? part
        return true if part.text.alphabetic?
        return true if part.text == 'st.' # saint
        false
      end

      def state_pattern? part
        NYAddressor::constants(@region, :STATES).values.include? part.text
      end

      def postal_pattern? part
        format = NYAddressor::constants(@region, :POSTAL_FORMATS)
        !!(part.text =~ format)
      end

      def country_pattern? part
        NYAddressor::constants(@region, :COUNTRY_IDENTIFIERS).values.include? part.text
      end

      def confirm_options
        # Postals are easiest to find
        # Whatever is after is probably the country
        # Whatever is before is probably city/state
        confirm_postal

        # If there is no postal, state is next easiest to find
        confirm_state
        confirm_country

        confirm_street_number
        confirm_street_label
        confirm_street_direction

        # If we know the number and a label or direction
        # the street name will be whatever remains
        confirm_street_name

        # A unit will be in it's own comma group
        # or after the street label
        confirm_unit

        # If we know the street and state, city is what remains
        confirm_city
      end

      def confirm_postal
        parts = potential(AddressField::POSTAL)
        parts&.last&.confirm(AddressField::POSTAL)
      end

      def confirm_state
        postal = get_field(AddressField::POSTAL)
        parts = potential(AddressField::STATE)

        # State must come before postal code
        parts.select! {|part| part.position < postal.position} if postal

        parts&.last&.confirm(AddressField::STATE)
      end

      def confirm_country
        # we know the country comes after state/postal
        known_after = [AddressField::STATE, AddressField::POSTAL]
        parts = potential_between(AddressField::COUNTRY, known_after)
        parts&.last&.confirm(AddressField::COUNTRY)
      end

      def confirm_street_number
        parts = potential(AddressField::STREET_NUMBER).select {|part| part.text.numeric? }
        parts = potential(AddressField::STREET_NUMBER).select {|part| part.text.has_digits? } if parts.empty?
        return if parts.empty?

        # Take the longest number if multiple candidates
        longest_part = parts.max_by {|part| part.text.length }

        longest_part.confirm(AddressField::STREET_NUMBER)
      end

      def confirm_street_label
        known_after = [AddressField::STREET_NUMBER]
        known_before = [AddressField::COUNTRY, AddressField::POSTAL, AddressField::STATE]

        parts = potential_between(AddressField::STREET_LABEL, known_after, known_before)
        parts.first.confirm(AddressField::STREET_LABEL)
      end

      def confirm_street_direction
        known_after = [AddressField::STREET_NUMBER]
        known_before = [AddressField::COUNTRY, AddressField::POSTAL, AddressField::STATE]

        parts = potential_between(AddressField::STREET_DIRECTION, known_after, known_before)
        parts&.first&.confirm(AddressField::STREET_DIRECTION)
      end

      def confirm_unit
        potential(AddressField::UNIT)&.first&.confirm(AddressField::UNIT)
      end

      def confirm_street_name
        after_fields = [AddressField::STREET_NUMBER]
        before_fields = []
        (direction_touching_number? ? after_fields : before_fields) << AddressField::STREET_DIRECTION
        (label_touching_number? ? after_fields : before_fields) << AddressField::STREET_LABEL

        parts = potential_between(AddressField::STREET_NAME, after_fields, before_fields)
        parts&.first&.confirm(AddressField::STREET_NAME)
      end

      # Address is of the form 123 North Main St
      def direction_touching_number?
        dir = get_field(AddressField::STREET_DIRECTION)
        num = get_field(AddressField::STREET_NUMBER)
        return false if dir.nil? || num.nil?

        dir.position - 1 == num.position
      end

      # Address is of the form ???
      def label_touching_number?
        lbl = get_field(AddressField::STREET_LABEL)
        num = get_field(AddressField::STREET_NUMBER)
        return false if lbl.nil? || num.nil?

        lbl.position - 1 == num.position
      end

      def confirm_city
        known_after = [AddressField::STREET_NAME, AddressField::STREET_LABEL, AddressField::STREET_DIRECTION]
        known_before = [AddressField::STATE, AddressField::POSTAL, AddressField::COUNTRY]
        parts = potential_between(AddressField::CITY, known_after, known_before)
        parts&.first&.confirm(AddressField::CITY)
      end
    end
  end
end
