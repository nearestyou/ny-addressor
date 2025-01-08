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
    result = input.dup.extend(AddressHelper).remove_description.remove_cross_street.separate_unit
    types_to_process = %i[COUNTRY_IDENTIFIERS STATES STREET_NUMBERS STREET_DIRECTIONS STREET_LABELS UNIT_DESIGNATIONS]
    types_to_process.each do |type|
      constants(region, type).each do |full_string, abbreviation|
        result.gsub!(/\b#{full_string}\b/i, abbreviation)
      end
    end
    result
  end

  module AddressHelper
    # Whole Foods Market, 1500... -> 1500 Penn Ave
    def remove_description
      first_part = self.split(',').first
      unless first_part.match(/\d+/)
        self.sub!(/
                  ^       # Only look at start
                  [^,]+,  # Grab everything, except the first comma
                  \s*     # Match any whitespace after the comma
                 /x, '')
      end
      self.extend(AddressHelper)
    end

    # 1505 & 1510 -> 1505
    def remove_cross_street
      self.gsub(/(\d+)\s*&\s*\d+/, '\1').extend(AddressHelper)
    end

    def separate_unit
      unit_postfix = /
        \s*[-]?\s*      # Optional dash around spaces
        [a-zA-Z]{1}     # Match ONE letter
        \d*             # 0 or more numbers
      /x

      # Match patterns like 1600-A, 1600A
      regex = /
        \A                 # Only look at first word
        (\d+)              # Digit
        (#{unit_postfix})
        \b
      /x
      self.sub!(regex) do |match|
        "##{$2.delete('-').strip} #{$1}"
      end

      unit_prefix =/
        [a-zA-Z]{1}     # ONE letter
        \d*             # 0 or more numbers
        \s*[-]\s*       # dash, optional spaces
      /x

      # Match patterns like A-1600 or A1-1600
      regex = /
        \A                 # Only look at first word
        (#{unit_prefix})
        (\d+)              # Digit
        \b
      /x
      self.sub!(regex) do |match|
        "##{$1.delete('-').strip} #{$2}"
      end

      # Match patterns like 100-1500
      regex = /
        \A            # Only look at first word
        (\d+)         # Digit (unit number)
        \s*[\/-]\s*   # hyphen or slash
        (\d+)         # Digit (street number)
        \b
      /x
      self.sub(regex, '#\1 \2').extend(AddressHelper)
    end
  end
end
