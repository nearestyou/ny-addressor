# frozen_string_literal: true
require 'digest'
module NYAddressor
  class Fingerprinter
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

    # @param parts [Hash{Symbol=>String}] parsed address components
    # @return [String,nil]
    def self.construct(parts, opts = {})
      required = %i[house_number street_name state]
      return nil if required.any? { |f| parts[f].to_s.empty? }

      opts = {
        include_label: false,
        include_dir: false,
        include_unit: true,
        include_city: true,
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
        when :city
          include_set << field if opts[:include_city]
        when :postcode
          include_set << field if opts[:include_postcode]
        when :country
          include_set << field if opts[:include_country]
        end
      end

      tokens = include_set.map do |field|
        next if parts[field].to_s.empty?

        if field == :postcode
          val = opts[:overwrite_postcode] ? "99999" : parts[:postcode].to_s
          next if val.empty?
          val
        else
          parts[field].to_s
        end
      end.compact

      tokens.join("").strip.gsub(/\s+/, "").downcase
    end

    # @param parts [Hash{Symbol=>String}] parsed address components
    # @return [Hash{Symbol=>String}]
    def self.all(parts)
      {
        full: Digest::SHA256.hexdigest(construct(parts)),
        zipless: Digest::SHA256.hexdigest(construct(parts, {overwrite_postcode: true})),
        unitless: Digest::SHA256.hexdigest(construct(parts, {include_unit: false})),
        countryless: Digest::SHA256.hexdigest(construct(parts, {include_country: false})),
        sns: Digest::SHA256.hexdigest(construct(parts, {
          include_unit: false,
          include_city: false,
          include_postcode: false,
          include_country: false
        }))
      }
    end
  end
end
