# frozen_string_literal: true
require 'digest'
require_relative 'extensions/string'
require_relative 'ny-addressor/constants'
require_relative 'ny-addressor/utils'
require_relative 'ny-addressor/address_field'
require_relative 'ny-addressor/parsers/generic_parser'
require_relative 'ny-addressor/parsers/german_parser'

module NYAddressor

  def self.new(*args)
    Addressor.new(*args)
  end

  class Addressor
    attr_reader :parser, :region

    # @return [Hash] countries with supported address parsers
    def self.get_capabilities
      {:AUTO => "Auto-detect"}.merge(Constants::COUNTRIES)
    end

    # Detects which region an address is from based on it's postal and state information
    #
    # @param address [String] the full address
    # @return [Symbol, nil] detected region or nil if not found
    def self.detect_region address
      formats = NYAddressor::Constants::POSTAL_FORMATS
      matches = []

      formats.each do |region, regex|
        match = address.match(regex)
        matches << { name: region, position: match.begin(0) } if match
      end

      return if matches.empty?

      possible_regions = matches.sort_by { |match| match[:position] }.reverse.map { |m| m[:name] }
      possible_regions.each do |region|
        return region if state_matches_region?(address, region)
      end

      nil
    end

    # @param address [String] address to check
    # @param region [Symbol] Region to check against
    # @return [Boolean] `true` if the address contains a state found in input region
    def self.state_matches_region?(address, region)
      states = NYAddressor::Constants::STATES[region]
      return false unless states
      address = address.downcase

      states.each do |name, abbr|
        regex = /\b(#{Regexp.escape(name)}|#{Regexp.escape(abbr)})\b/
        return true if address.match?(regex)
      end
      false
    end

    # @param full_address [String] A full address
    # @param country [Symbol] The country code, or `:AUTO` for auto-detection
    def initialize(full_address, country = :AUTO)
      return if full_address.nil? || full_address.length < 4
      @input = full_address
      @region = country == :AUTO ? Addressor::detect_region(full_address) : country
      return unless @region

      @parser = case @region
                when :DE
                  NYAddressor::Parsers::GermanParser.new(@input, @region)
                else
                  NYAddressor::Parsers::GenericParser.new(@input, @region)
                end
    end

    # Compares two Addressor objects for equality based on their hash
    #
    # @param other [Addressor]
    # @return [Boolean] `true` if they match
    def ==(other)
      return false unless other.is_a?(Addressor)
      self.hash == other.hash
    end

    # @return [String] normalized address string
    def to_s
      construct
    end

    # @return [String] a defailted representation of the addressor instance
    def inspect
      "#<NYAddressor::Addressor(#{@input}, #{@region}): #{to_s}"
    end

    # @return [String] formatted debugging information
    def debug
      output = inspect
      @parser.parts.flatten.each {|part| output << "\n#{part.debug}" }
      output
    end

    def parts
      AddressField.constants.each_with_object({}) do |field, result|
        key = AddressField.const_get(field)
        values = @parser.get_field(key, all: true)
        value = values.map(&:text).join(" ")
        result[key] = value unless value.empty?
      end
    end

    # Constructs a standardized address string based on parsed fields
    #
    # @param opts [Hash] Options for including/excluding fields
    # @return [String, nil] The constructed address
    def construct(opts = {})
      required_fields = [AddressField::STREET_NUMBER, AddressField::STREET_NAME, AddressField::STATE]
      return nil if required_fields.any? { |field| @parser&.get_field(field).nil? }

      opts = {
        include_unit: true,
        include_label: true,
        include_dir: true,
        include_city: true,
        include_postal: true,
        include_country: false,
        overwrite_postal: false
      }.merge(opts)

      fields = required_fields
      fields << AddressField::CITY if opts[:include_city]
      fields << AddressField::UNIT if opts[:include_unit]
      fields << AddressField::STREET_LABEL if opts[:include_label]
      fields << AddressField::STREET_DIRECTION if opts[:include_dir]
      fields << AddressField::COUNTRY if opts[:include_country]

      addr_str = fields.map do |field|
        parts = @parser.get_field(field, all: true)
        next if parts.empty?

        parts.map(&:text)
      end.flatten.compact.join

      if opts[:include_postal]
        addr_str << (opts[:overwrite_postal] ? '99999' : @parser.get_field(AddressField::POSTAL).to_s)[0..4]
      end

      addr_str.standardize
    end

    # @return [String, nil] The hash value
    def hash
      _hash(construct)
    end

    # @return [String, nil] The hash value, not taking unit field into consideration
    def unitless_hash
      _hash(construct({ include_unit: false }))
    end

    # @return [String, nil] The hash value, not taking postal code into consideration
    def hash99999
      _hash(construct({ overwrite_postal: true }))
    end

    # @return [String, nil] Street number, name, and state
    def sns
      construct({
        include_unit: false,
        include_label: false,
        include_dir: false,
        include_city: false,
        include_postal: false,
        include_country: false
      })
    end

    # Compares two Addressor instances for similarity
    #
    # @param other [Addressor] Another instance to compare to
    # @return [Float] A score between 0 and 1 representing similarity
    def compare(other)
      return 0 unless other.is_a?(Addressor)
      return 0 unless other.parser
      return 0 unless self.parser

      fields_to_compare = [
        { name: AddressField::STREET_NUMBER, weight: 1.0 },
        { name: AddressField::STREET_NAME, weight: 1.0 },
        { name: AddressField::STATE, weight: 1.0 },
        { name: AddressField::CITY, weight: 0.5 },
        { name: AddressField::UNIT, weight: 0.25 },
        { name: AddressField::POSTAL, weight: 0.8 },
      ]

      score = 0
      weight = 0

      fields_to_compare.each do |field|
        self_field = self.parser.get_field(field[:name])&.text.to_s.strip.downcase
        other_field = other.parser.get_field(field[:name])&.text.to_s.strip.downcase
        match_score = self_field == other_field ? 1 : NYAddressor::string_inclusion(self_field, other_field, true)
        score += match_score * field[:weight]
        weight += field[:weight]
      end

      score / weight
    end

    private

    def _hash input
      return unless input
      Digest::SHA256.hexdigest(input)[0..23]
    end

  end
end
