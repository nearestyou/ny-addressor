# frozen_string_literal: true
require 'digest'
require "countries"
module NYAddressor
  module Fingerprinter
    DEFAULT_ORDER = %i[
      house_number
      street_name
      street_label
      street_direction
      unit
      city
      state
      postcode
      country
    ].freeze

    module_function

    # @param parts [Hash{Symbol=>String}] parsed address components
    # @return [String,nil]
    def construct(parts, opts = {})
      required = %i[house_number street_name city]
      return nil if required.any? { |f| parts[f].to_s.empty? }

      opts = {
        include_label: false,
        include_dir: false,
        include_unit: true,
        include_state: true,
        include_postcode: true,
        include_country: true,
        overwrite_postcode: false
      }.merge(opts)

      include_set = required
      DEFAULT_ORDER.each do |field|
        case field
        when :street_label
          include_set << field if opts[:include_label]
        when :street_direction
          include_set << field if opts[:include_dir]
        when :unit
          include_set << field if opts[:include_unit]
        when :state
          include_set << field if opts[:include_state]
        when :postcode
          include_set << field if opts[:include_postcode]
        when :country
          include_set << field if opts[:include_country]
        end
      end

      tokens = include_set.map do |field|
        if field == :postcode && opts[:overwrite_postcode]
          "99999"
        else
          res = parts[field].to_s
          next if res.empty?

          res
        end
      end.compact

      tokens.join("").strip.gsub(/\s+/, "").downcase
    end

    # @param parts [Hash{Symbol=>String}] parsed address components
    # @return [Hash{Symbol=>String}]
    def all(parts)
      variants = {
        full: {},
        zipless: { overwrite_postcode: true },
        unitless: { include_unit: false },
        countryless: { include_country: false },
        sns: {
          include_unit: false,
          include_state: false,
          include_postcode: false,
          include_country: false
        }
      }

      variants.transform_values do |opts|
        str = construct(parts, opts)
        str ? Digest::SHA256.hexdigest(str) : nil
      end
    end
  end
end
