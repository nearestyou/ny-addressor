module NYAddressor
  # Fetches constatns for specific region and  type
  # @param region [Symbol] :US, :UK, etc
  # @param type [Symbol] :STREET_LABELS, :UNIT_DESCRIPTORS, etc
  # @return [Hash|List]
  def self.constants(region, type)
    begin
      region_map = Constants.const_get(type)[region]
      return region_map if region_map
    rescue
    end
    Constants::Generics.const_get(type)
  end

  # Normalize a string for a given region
  def self.normalize(input, region)
    result = input.dup.extend(AddressHelper)
    types_to_process = %i[COUNTRY_IDENTIFIERS STATES STREET_NUMBERS STREET_DIRECTIONS STREET_LABELS UNIT_DESIGNATIONS]
    types_to_process.each do |type|
      constants(region, type).each do |full_string, abbreviation|
        result.gsub!(/\b#{full_string}\b/i, abbreviation)
      end
    end
    result.remove_cross_street.separate_unit
  end

  module AddressHelper
    # 1505 & 1510 -> 1505
    def remove_cross_street
      self.gsub(/(\d+)\s*&\s*\d+/, '\1').extend(AddressHelper)
    end

    # 100-1500 -> #100 1500
    def separate_unit
      regex = /
        \A      # Only look at first word
        (\d+)   # Digit
        [\/-]   # hyphen or slash
        (\d+)
      /x
      self.sub(regex, '#\1 \2').extend(AddressHelper)
    end
  end
end
