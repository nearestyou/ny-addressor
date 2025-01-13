# frozen_string_literal: true
require 'digest'
require_relative 'extensions/string'
require_relative 'ny-addressor/constants'
require_relative 'ny-addressor/utils'
require_relative 'ny-addressor/address_field'
require_relative 'ny-addressor/parsers/generic_parser'

module NYAddressor

  class Addressor
    attr_reader :parser
    def self.get_capabilities
      {:AUTO => "Auto-detect"}.merge(Constants::COUNTRIES)
    end

    def self.detect_region full_address
      formats = NYAddressor::Constants::POSTAL_FORMATS
      matches = []

      formats.each do |region, regex|
        match = full_address.match(regex)
        matches << { name: region, position: match.begin(0) } if match
      end

      return if matches.empty? # default to US

      matches.max_by { |match| match[:position] }[:name]
    end

    def initialize(full_address, country = :AUTO)
      return if full_address.nil? || full_address.length < 4
      @input = full_address
      @region = country == :AUTO ? Addressor::detect_region(full_address) : country
      @parser = NYAddressor::Parsers::GenericParser.new(@input, @region)
      # puts debug
    end

    def ==(other)
      return false unless other.is_a?(Addressor)
      self.hash == other.hash
    end

    def to_s
      construct
    end

    def inspect
      "#<NYAddressor::Addressor(#{@input}, #{@region}): #{to_s}"
    end

    def debug
      output = inspect
      @parser.parts.flatten.each {|part| output << "\n#{part.debug}" }
      output
    end

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

      addr_str = fields.map {|field| @parser.get_field(field)}.compact.map(&:to_s).join

      if opts[:include_postal]
        addr_str << (opts[:overwrite_postal] ? '99999' : @parser.get_field(AddressField::POSTAL).to_s)[0..4]
      end

      addr_str.standardize
    end

    def hash
      _hash(construct)
    end

    def unitless_hash
      _hash(construct({ include_unit: false }))
    end

    # for searching by missing/erroneous ZIP
    def hash99999
      _hash(construct({ overwrite_postal: true }))
    end

    # Street num/name + state
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

    def compare(other)
      return 0 unless other.is_a?(Addressor)

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
