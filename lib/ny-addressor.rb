# frozen_string_literal: true
require 'digest'
require_relative 'extensions/string'
require_relative 'ny-addressor/constants'
require_relative 'ny-addressor/address_field'
require_relative 'ny-addressor/parsers/generic_parser'

module NYAddressor

  class Addressor
    def self.get_capabilities
      {:AUTO => "Auto-detect"}.merge(Constants::COUNTRIES)
    end

    def initialize(full_address, country = :AUTO)
      @input = full_address
      @region = country
      return if full_address.nil? || full_address.length < 4
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
        include_postal: true,
        include_country: false,
        overwrite_postal: false
      }.merge(opts)

      fields = required_fields + [AddressField::CITY]
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
        include_postal: false,
        include_country: false
      })
    end

    private

    def _hash input
      return unless input
      Digest::SHA256.hexdigest(input)[0..23]
    end

  end
end

# # Addressor
# class NYAddressor
#   attr_reader :sep_map, :input, :parts, :confirmed
#
#   def initialize(input)
#     reset(input)
#   end
#
#   def self.determine_state(state_name, postal_code = nil)
#     AddressorUtils.determine_state(state_name, postal_code)
#   end
#
#   def self.string_inclusion(str1, str2, numeric_failure: false)
#     AddressorUtils.string_inclusion(str1, str2, numeric_failure)
#   end
#
#   def self.comp(*args)
#     AddressorUtils.comp(*args)
#   end
#
#   def comp(nya, comparison_keys = %i[street_number street_name postal])
#     AddressorUtils.comp(@parts, nya.parts, comparison_keys)
#   end
#
#   def construct(opts = {})
#     return nil unless @parts
#     return nil unless @parts.slice(:street_number, :street_name, :state).keys.length == 3
#
#     opts = { include_unit: true, include_label: true, include_dir: true, include_postal: true }.merge(opts)
#     addr = "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:city]}#{@parts[:state]}"
#     return nil if addr.length < 2
#
#     addr << @parts[:unit].to_s if opts[:include_unit]
#     addr << @parts[:street_label].to_s if opts[:include_label]
#     addr << @parts[:street_direction].to_s if opts[:include_dir]
#     addr << (@parts[:postal] || '99999').to_s[0..4] if opts[:include_postal]
#     addr.standardize.unrepeat
#   end
