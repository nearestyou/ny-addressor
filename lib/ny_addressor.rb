# frozen_string_literal: true

load 'lib/addressor_utils.rb'
load 'lib/ny_address_part.rb'
require 'digest'
require 'byebug'

# Addressor
class NYAddressor
  attr_reader :sep_map, :input, :parts, :confirmed

  def initialize(input)
    return if input.nil? || input.length < 4

    @confirmed = {}
    @input = input
    # @sep_comma = @input.split(',').map { |p| p.clean.strip.split unless p.strip.empty? }.reject(&:nil?)
    @sep_comma = preformat(@input).unrepeat.split(',').map { |p| p.clean.strip.split unless p.strip.empty? }.reject(&:nil?)
    @sep = @sep_comma.flatten
    create_sep_map
    confirm_options
    set_parts
  end

  def self.determine_state(state_name, postal_code = nil)
    AddressorUtils.determine_state(state_name, postal_code)
  end

  def clean
    @input.clean
  end

  def construct(opts = {})
    return nil unless @parts
    return nil unless @parts.slice(:street_number, :street_name, :state).keys.length == 3

    opts = { include_unit: true, include_label: true, include_dir: true, include_postal: true }.merge(opts)
    addr = "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:city]}#{@parts[:state]}"
    return nil if addr.length < 2

    addr << @parts[:unit].to_s if opts[:include_unit]
    addr << @parts[:street_label].to_s if opts[:include_label]
    addr << @parts[:street_direction].to_s if opts[:include_dir]
    addr << (@parts[:postal] || '99999').to_s[0..4] if opts[:include_postal]
    addr.standardize.unrepeat
  end

  def hash
    k = construct
    return nil unless k

    Digest::SHA256.hexdigest(k)[0..23]
  end

  def unitless_hash
    k = construct({ include_unit: false })
    return nil unless k

    Digest::SHA256.hexdigest(k)[0..23]
  end

  # for searching by missing/erroneous ZIP
  def hash99999
    return nil unless @parts

    Digest::SHA256.hexdigest(construct[0..-6] << '99999')[0..23]
  end

  # Street num/name + state
  def sns
    return '' unless @parts
    return '' unless @parts[:street_number] && @parts[:street_name] && @parts[:state]

    "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:state]}".standardize
  end

  # Equality functions used for testing
  def ==(other)
    eq(other.parts)
  end

  def eq(parts)
    return nil unless @parts
    return false unless @parts[:street_number].to_s.standardize == parts[:street_number].to_s.standardize
    return false unless @parts[:street_name].to_s.standardize == parts[:street_name].to_s.standardize
    return false unless @parts[:street_label].to_s.standardize == parts[:street_label].to_s.standardize
    return false unless @parts[:street_direction].to_s.standardize == parts[:street_direction].to_s.standardize
    return false unless @parts[:unit].to_s.standardize == parts[:unit].to_s.standardize
    return false unless @parts[:city].to_s.standardize == parts[:city].to_s.standardize
    return false unless @parts[:state].to_s.standardize == parts[:state].to_s.standardize
    return false unless @parts[:postal].to_s.standardize == parts[:postal].to_s.standardize
    return false unless @parts[:country].to_s.standardize == parts[:country].to_s.standardize

    true
  end

  ### PRIVATE METHODS ###
  private

  def preformat(str)
    result = str.dup
    # Remove corner stores
    # TODO: Only do this for numbers?
    while result.include?('&')
      location = result.index('&')
      pre_location = location - (result[0..location - 1].strip.reverse.index(' ') || location)
      remove_str = result[pre_location..location]
      result = result.sub(remove_str, '').strip
    end

    result
  end

  def create_sep_map
    @sep_map = []

    @sep_comma.each_with_index do |comma, comi|
      comma.each_with_index do |p, _pi|
        part = NYAddressPart.new(p)
        part.position_options(@sep_map.length, @sep.length)
        # part.comma_options(comi, pi, comma.length, @sep_comma.length)
        part.comma_options(comi, @sep_comma.length)
        part.consolidate_options
        @sep_map << part
      end
    end
  end

  def set_parts
    return if @confirmed.keys.length < 3

    @parts = { orig: @input }
    @confirmed.each do |label, indexes|
      @parts[label] = indexes.map { |i| NYAConstants::STANDARDIZE_ALL[@sep_map[i].text] || @sep_map[i].text }.join(' ')
    end

    @parts.each do |label, part|
      @parts[label] = NYAConstants::STANDARDIZE_ALL[part] || part
    end

    unfound = (0...@sep_map.length).to_a - confirmed_positions
    @parts[:bus] = unfound.map { |i| @sep_map[i] }
    assume_parts
    cleanup_parts
  end

  # Based on what's in the bus
  def assume_parts
    # Check if unit is in street number
    # 1) If street number has - or / unit is the smallest length
    # 2) If street number is all nums except 1 letter, letter is unit
    search_for_unit_in_street_num if @parts[:unit].nil? && @parts[:street_number]
  end

  def search_for_unit_in_street_num
    if @parts[:street_number].letter_count == 1
      @parts[:unit] = @parts[:street_number].strip_digits
      @parts[:street_number] = @parts[:street_number].strip_letters
      return
    end

    sn = @parts[:street_number].split(%r{[-/]}, 2)
    return unless sn.length == 2

    unit = sn.min { |x, y| x.size <=> y.size }
    unit_pos = @parts[:street_number].index(unit) - 2
    @parts[:unit] = unit.strip
    after = @parts[:street_number][unit_pos + unit.length + 3..]
    before = unit_pos.negative? ? '' : @parts[:street_number][0..unit_pos]
    @parts[:street_number] = before + after
  end

  def cleanup_parts
    @parts[:postal] = @parts[:postal].gsub(/o|O/, '0') if @parts[:postal]
    NYAConstants::UNIT_DESCRIPTORS.each { |desc| @parts[:unit] = @parts[:unit].gsub(desc, '').strip } if @parts[:unit]
  end

  # Find potential matches for this symbol
  def potential(sym)
    @sep_map.each_index.select { |i| @sep_map[i].from_all.include? sym }
  end

  # Find indexes of symbols that have been confirmed
  # @param {Symbol[]} syms - Symbols to look for
  # @return {int[]} - Array of indexes where those symbols are confirmed
  def confirmed_positions(syms = nil)
    syms ||= @confirmed.keys
    result = []
    @confirmed.slice(*syms).each_value do |i|
      i.each { |i2| result << i2 }
    end
    result
  end

  def confirmed_map(syms = nil)
    confirmed_positions(syms).map { |i| @sep_map[i] }
  end

  def confirm_options
    # Postals are the easiest to find
    # Whatever is after is probably the country!
    # Whatever is before is probaby city/state
    confirm_postal

    # Must confirm state first
    # Because it's easier than country to detect
    # When no postal is present
    confirm_state
    confirm_country

    # Street number is probably the next easiest thing to find
    confirm_street_number
    confirm_street_label
    confirm_street_direction

    confirm_unit
    # name is between number && (label || direction)
    confirm_street_name
    # city is between (label || direction || name) && (state || postal)
    confirm_city
  end

  def confirm_postal
    potential = @sep_map.each_index.select { |i| @sep_map[i].from_all.include? :postal }
    return if potential.empty?

    @confirmed[:postal] = potential if potential.map { |i| @sep_map[i].typified }.join.delete(' ') == '=|=|=|'
    @confirmed[:postal] ||= [potential.last]
  end

  def confirm_state
    potential = @sep_map.each_index.select { |i| @sep_map[i].from_all.include? :state }
    confirm = @confirmed[:postal] ? potential.select { |i| i < @confirmed[:postal].min } : potential
    last_comma_block = confirm.map { |i| @sep_map[i].comma_block || nil }.max
    confirm = confirm.select { |i| @sep_map[i].comma_block.to_i == last_comma_block } if last_comma_block

    @confirmed[:state] = confirm unless confirm.empty?
  end

  def confirm_country
    known_after = @confirmed[:state].max if @confirmed[:state]
    known_after = @confirmed[:postal].max if @confirmed[:postal]
    confirm = potential(:country).select { |i| i > known_after } if known_after
    @confirmed[:country] = confirm if confirm && !confirm.empty?
  end

  def confirm_street_number
    nums = potential(:street_number).select { |i| @sep_map[i].text.numeric? }
    nums = potential(:street_number).select { |i| @sep_map[i].text.has_digits? } if nums.empty?
    @confirmed[:street_number] = [nums.min] unless nums.empty?
    @confirmed[:street_number] = nums if nums.map { |i| @sep_map[i].typified }.join == '=|||=|||||' # Wisconsin
  end

  def confirm_street_label
    known_after = confirmed_positions(%i[street_number]).max
    known_before = confirmed_positions(%i[country postal state]).min

    confirm = potential(:street_label)
    confirm = confirm.select { |i| i < known_before } if known_before
    confirm = confirm.select { |i| i > known_after } if known_after
    @confirmed[:street_label] = confirm if confirm && !confirm.empty?
  end

  def confirm_street_direction
    known_after = confirmed_positions(%i[street_number]).max
    known_before = confirmed_positions(%i[country postal state]).min

    confirm = potential(:street_direction)
    confirm = confirm.select { |i| i < known_before } if known_before
    confirm = confirm.select { |i| i > known_after } if known_after
    @confirmed[:street_direction] = confirm if confirm && !confirm.empty?
  end

  def confirm_unit
    confirm = potential(:unit).reject { |i| confirmed_positions.include? i }
    @confirmed[:unit] = confirm if confirm && !confirm.empty?
  end

  def confirm_street_name
    known_after = %i[street_number]
    known_before = []

    (direction_touching_number? ? known_after : known_before) << :street_direction
    (label_touching_number? || highway_street? ? known_after : known_before) << :street_label
    known_before = confirmed_positions(known_before).min
    known_after = confirmed_positions(known_after).max

    # TODO: Select everything within the same comma_block
    confirm = potential(:street_name)
    confirm = confirm.select { |i| i < known_before } if known_before
    confirm = confirm.select { |i| i > known_after } if known_after
    @confirmed[:street_name] = confirm if confirm && !confirm.empty?
  end

  def confirm_city
    # TODO: Select everything within the same comma_block
    known_after = confirmed_positions(%i[street_label street_direction]).max
    known_before = confirmed_positions(%i[postal country state]).min

    confirm = potential(:city).reject { |i| confirmed_positions.include? i }
    confirm = confirm.select { |i| i < known_before } if known_before
    confirm = confirm.select { |i| i > known_after } if known_after
    @confirmed[:city] = confirm if confirm && !confirm.empty?
  end

  ### Methods for finding specific things about an address

  def direction_touching_number?
    return false unless @confirmed[:street_direction] && @confirmed[:street_number]

    @confirmed[:street_direction].min - 1 == @confirmed[:street_number].max
  end

  def label_touching_number?
    confirmed_positions(%i[street_number street_label]).length > 1 &&
      @confirmed[:street_label].min - 1 == @confirmed[:street_number].max
  end

  def highway_street?
    confirmed_map(%i[street_label]).map(&:text).include? 'hwy'
  end
end

#  def comp(nya, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(@addressor.parts, nya.addressor.parts, comparison_keys); end
#
#  def self.string_inclusion(str1, str2, numeric_failure = false); AddressorUtils.string_inclusion(str1, str2, numeric_failure); end
#  #def self.comp(parts1, parts2, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(parts1, parts2, comparison_keys); end
#  def self.comp(*args); AddressorUtils.comp(*args); end
