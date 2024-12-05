# frozen_string_literal: true
require_relative '../address_part'
require_relative '../../extensions/string'
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
      end
    end
  end
end
