# frozen_string_literal: true

load 'lib/addressor_utils.rb'
load 'lib/ny_address_part.rb'
require 'byebug'

# Addressor
class NYAddressor
  # attr_accessor :input, :parts
  attr_reader :sep_map, :input, :parts, :confirmed

  def initialize(input)
    return if input.nil? || input.length < 4

    @confirmed = {}
    @input = input
    @clean = clean(input)
    @sep = @clean.split
    @sep_comma = @input.split(',').map { |p| clean(p).strip.split }
    create_sep_map
    confirm_options
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

  def clean(str)
    str&.gsub(/\s*\(.+\)$/, '')&.gsub(',', ' ')&.delete("'")&.downcase&.gsub("\u00A0", ' ')
    # regex: https://stackoverflow.com/questions/8708515/ruby-rails-remove-text-inside-parentheses-from-a-string
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
    (@confirmed[:postal] ||= []) << potential.last
    # TODO: Multipostal logic
  end

  def confirm_state
    potential = @sep_map.each_index.select { |i| @sep_map[i].from_all.include? :state }
    confirm = @confirmed[:postal] ? potential.select { |i| i < @confirmed[:postal].min } : potential
    (@confirmed[:state] ||= []) << confirm.last unless confirm.empty?
    # TODO: Multistate logic
  end

  def confirm_country
    known_after = @confirmed[:state].max if @confirmed[:state]
    known_after = @confirmed[:postal].max if @confirmed[:postal]
    confirm = potential(:country).select { |i| i > known_after } if known_after
    @confirmed[:country] = confirm if confirm && !confirm.empty?
  end

  def confirm_street_number
    nums = potential(:street_number).select { |i| @sep_map[i].text.numeric? }
    @confirmed[:street_number] = [nums.min] unless nums.empty?
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
    if direction_touching_number?
      known_before = confirmed_positions(%i[street_label]).min
      known_after = confirmed_positions(%i[street_number street_direction]).max
    elsif highway_street?
      # Highway is a label, the name comes after
      known_before = confirmed_positions(%i[street_direction]).min
      known_after = confirmed_positions(%i[street_label]).max
    else
      known_before ||= confirmed_positions(%i[street_label street_direction]).min
      known_after ||= confirmed_positions(%i[street_number]).max
    end

    # debugger
    confirm = potential(:street_name)
    confirm = confirm.select { |i| i < known_before } if known_before
    confirm = confirm.select { |i| i > known_after } if known_after
    @confirmed[:street_name] = confirm if confirm && !confirm.empty?
  end

  def confirm_city
    known_after = confirmed_positions(%i[street_label street_direction]).max
    known_before = confirmed_positions(%i[postal country state]).min

    confirm = potential(:city).reject { |i| confirmed_positions.include? i }
    confirm = confirm.select { |i| i < known_before } if known_before
    confirm = confirm.select { |i| i > known_after } if known_after
    @confirmed[:city] = confirm if confirm && !confirm.empty?
  end


  ### Methods for finding specific things about an address

  def direction_touching_number?
    confirmed_positions(%i[street_number street_direction]).length > 1 && @confirmed[:street_direction].min - 1 == @confirmed[:street_number].max
  end

  def highway_street?
    confirmed_map(%i[street_label]).map(&:text).include? 'hwy'
  end
end



#  def potential_ca
#    typified = AddressorUtils.typify(@input)
#    typified.include?('=|= |=|') or typified.include?('=|=|=|')
#  end
#
#  ## Manually inheriting methods from region specific addressor
#  def construct(opts = {}); @addressor.construct(opts); end
#  def hash; @addressor.hash; end
#  def hash99999; @addressor.hash99999; end
#  def unitless_hash; @addressor.unitless_hash; end
#  def sns; @addressor.sns; end
#  def comp(nya, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(@addressor.parts, nya.addressor.parts, comparison_keys); end
#
#  def self.string_inclusion(str1, str2, numeric_failure = false); AddressorUtils.string_inclusion(str1, str2, numeric_failure); end
#  def self.determine_state(state_name, postal_code = nil); AddressorUtils.determine_state(state_name, postal_code); end
#  #def self.comp(parts1, parts2, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(parts1, parts2, comparison_keys); end
#  def self.comp(*args); AddressorUtils.comp(*args); end
#
#end
