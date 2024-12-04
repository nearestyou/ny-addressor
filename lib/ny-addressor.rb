# frozen_string_literal: true
require_relative 'ny-addressor/constants'

module NYAddressor
  class Addressor
    def self.get_capabilities
      {:AUTO => "Auto-detect"}.merge(Constants::COUNTRIES)
    end

    def initialize(full_address, country = :AUTO)
    end
  end
end

# require 'digest'
# if ENV['LOCAL_DEPENDENCIES']
#   load 'lib/addressor_utils.rb'
#   load 'lib/ny_address_part.rb'
#   require 'byebug'
# else
#   require 'addressor_utils.rb'
#   require 'ny_address_part.rb'
# end
#
# # Addressor
# class NYAddressor
#   attr_reader :sep_map, :input, :parts, :confirmed
#
#   def initialize(input)
#     reset(input)
#   end
#
#   # PUBLIC METHODS
#   # ###
#   def to_s
#     output = "Addressor(#{@input})"
#     output << "\nParts: #{@parts.except(:bus)}"
#     output << "\nBus: #{@parts[:bus].map(&:text)}"
#     output << "\nConstruction: #{construct}  | #{sns}"
#     output << "\nHASHES: unitless: #{unitless_hash}  |  generic zip: #{hash99999}  |  default: #{hash}"
#     output
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
#   def clean
#     @input.clean
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
#
#   def hash
#     k = construct
#     return nil unless k
#
#     Digest::SHA256.hexdigest(k)[0..23]
#   end
#
#   def unitless_hash
#     k = construct({ include_unit: false })
#     return nil unless k
#
#     Digest::SHA256.hexdigest(k)[0..23]
#   end
#
#   # for searching by missing/erroneous ZIP
#   def hash99999
#     return nil unless @parts
#
#     k = construct
#     return nil unless k
#
#     Digest::SHA256.hexdigest(construct[0..-6] << '99999')[0..23]
#   end
#
#   # Street num/name + state
#   def sns
#     return '' unless @parts
#     return '' unless @parts[:street_number] && @parts[:street_name] && @parts[:state]
#
#     "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:state]}".standardize
#   end
#
#   # Equality functions used for testing
#   def ==(other)
#     eq(other.parts)
#   end
#
#   def eq(parts)
#     return nil unless @parts
#     return false unless @parts[:street_number].to_s.standardize == parts[:street_number].to_s.standardize
#     return false unless @parts[:street_name].to_s.standardize == parts[:street_name].to_s.standardize
#     return false unless @parts[:street_label].to_s.standardize == parts[:street_label].to_s.standardize
#     return false unless @parts[:street_direction].to_s.standardize == parts[:street_direction].to_s.standardize
#     return false unless @parts[:unit].to_s.standardize == parts[:unit].to_s.standardize
#     return false unless @parts[:city].to_s.standardize == parts[:city].to_s.standardize
#     return false unless @parts[:state].to_s.standardize == parts[:state].to_s.standardize
#     return false unless @parts[:postal].to_s.standardize == parts[:postal].to_s.standardize
#     return false unless @parts[:country].to_s.standardize == parts[:country].to_s.standardize
#
#     true
#   end
#
#   ### PRIVATE METHODS ###
#   private
#
#   def reset(input)
#     @confirmed = {}
#     @input = input
#     return if input.nil? || input.length < 4
#
#     @sep_comma = preformat(@input).unrepeat.split(',').map{ |p| p.clean.strip.split unless p.strip.empty? }.reject(&:nil?)
#     @sep = @sep_comma.flatten
#
#     begin
#       create_sep_map
#       confirm_options
#       set_parts
#     rescue StandardError => e
#       puts "NYAddressor(#{input}) failed: #{e}"
#       return
#     end
#
#     return if hash || !@sep_comma || @sep_comma.length < 2
#     return if @sep_comma[0][0].has_digits? || !@sep_comma[1][0].has_digits?
#
#     reset(input.split(',')[1..].join(',').strip) # Recursively remove commas
#   end
#
#   def preformat(str)
#     result = str.dup
#     # Remove corner stores
#     # TODO: Only do this for numbers?
#     while result.include?('&')
#       location = result.index('&')
#       pre_location = location - (result[0..location - 1].strip.reverse.index(' ') || location)
#       remove_str = result[[0, pre_location].max..location]
#       result = result.sub(remove_str, '').strip
#     end
#
#     result
#   end
#
#   def create_sep_map
#     @sep_map = []
#
#     @sep_comma.each_with_index do |comma, comi|
#       comma.each_with_index do |p, _pi|
#         part = NYAddressPart.new(p)
#         part.position_options(@sep_map.length, @sep.length)
#         # part.comma_options(comi, pi, comma.length, @sep_comma.length)
#         part.comma_options(comi, @sep_comma.length)
#         part.consolidate_options
#         @sep_map << part
#       end
#     end
#   end
#
#   # Find potential matches for this symbol
#   def potential(sym)
#     @sep_map.each_index.select { |i| @sep_map[i].from_all.include? sym }
#   end
#
#   # Find indexes of symbols that have been confirmed
#   # @param {Symbol[]} syms - Symbols to look for
#   # @return {int[]} - Array of indexes where those symbols are confirmed
#   def confirmed_positions(syms = nil)
#     syms ||= @confirmed.keys
#     result = []
#     @confirmed.slice(*syms).each_value do |i|
#       i.each { |i2| result << i2 }
#     end
#     result
#   end
#
#   # Returns a list of confirmed indexes for these symbols
#   def confirmed_map(syms = nil)
#     confirmed_positions(syms).map { |i| @sep_map[i] }
#   end
#
#   ### Find things about the address we are 90% sure are true
#   #####################
#   def confirm_options
#     # Postals are the easiest to find
#     # Whatever is after is probably the country!
#     # Whatever is before is probaby city/state
#     confirm_postal
#
#     # Must confirm state first
#     # Because it's easier than country to detect
#     # When no postal is present
#     confirm_state
#     confirm_country
#
#     # Street number is probably the next easiest thing to find
#     confirm_street_number
#     confirm_street_label
#     confirm_street_direction
#
#     confirm_unit
#     # name is between number && (label || direction)
#     confirm_street_name
#     # city is between (label || direction || name) && (state || postal)
#     confirm_city
#   end
#
#   def confirm_postal
#     potential = @sep_map.each_index.select { |i| @sep_map[i].from_all.include? :postal }
#     return if potential.empty?
#
#     @confirmed[:postal] = potential if potential.map { |i| @sep_map[i].typified }.join.delete(' ') == '=|=|=|'
#     @confirmed[:postal] = potential if potential.map { |i| @sep_map[i].typified }.join.delete(' ') == '=||==' # G2 4QY
#     @confirmed[:postal] ||= [potential.last]
#   end
#
#   def confirm_state
#     potential = @sep_map.each_index.select { |i| @sep_map[i].from_all.include? :state }
#     confirm = @confirmed[:postal] ? potential.select { |i| i < @confirmed[:postal].min } : potential
#     last_comma_block = confirm.map { |i| @sep_map[i].comma_block || nil }.max
#     confirm = confirm.select { |i| @sep_map[i].comma_block.to_i == last_comma_block } if last_comma_block
#
#     @confirmed[:state] = confirm unless confirm.empty?
#   end
#
#   def confirm_country
#     known_after = @confirmed[:state].max if @confirmed[:state]
#     known_after = @confirmed[:postal].max if @confirmed[:postal]
#     confirm = potential(:country).select { |i| i > known_after } if known_after
#     @confirmed[:country] = confirm if confirm && !confirm.empty?
#   end
#
#   def confirm_street_number
#     nums = potential(:street_number).select { |i| @sep_map[i].text.numeric? }
#     nums = potential(:street_number).select { |i| @sep_map[i].text.has_digits? } if nums.empty?
#
#     # Take the longest one
#     @confirmed[:street_number] = [@sep_map.select { |sep| sep.text == nums.map{|n| @sep_map[n].text}.max_by(&:length) }.first.position] unless nums.empty?
#     @confirmed[:street_number] = nums if nums.map { |i| @sep_map[i].typified }.join == '=|||=|||||' # Wisconsin
#   end
#
#   def confirm_street_label
#     known_after = confirmed_positions(%i[street_number]).max
#     known_before = confirmed_positions(%i[country postal state]).min
#
#     confirm = potential(:street_label)
#     confirm = confirm.select { |i| i < known_before } if known_before
#     confirm = confirm.select { |i| i > known_after } if known_after
#     @confirmed[:street_label] = confirm if confirm && !confirm.empty?
#   end
#
#   def confirm_street_direction
#     known_after = confirmed_positions(%i[street_number]).max
#     known_before = confirmed_positions(%i[country postal state]).min
#
#     confirm = potential(:street_direction)
#     confirm = confirm.select { |i| i < known_before } if known_before
#     confirm = confirm.select { |i| i > known_after } if known_after
#     @confirmed[:street_direction] = confirm if confirm && !confirm.empty?
#   end
#
#   def confirm_unit
#     confirm = potential(:unit).reject { |i| confirmed_positions.include? i }
#     @confirmed[:unit] = confirm if confirm && !confirm.empty?
#   end
#
#   def confirm_street_name
#     # Treat highways differently
#     return if confirm_highway_street_name
#
#     known_after = %i[street_number]
#     known_before = []
#
#     (direction_touching_number? ? known_after : known_before) << :street_direction
#     (label_touching_number? ? known_after : known_before) << :street_label
#     known_before = confirmed_positions(known_before).min
#     known_after = confirmed_positions(known_after).max
#
#     # TODO: Select everything within the same comma_block
#     confirm = potential(:street_name)
#     confirm = confirm.select { |i| i < known_before } if known_before
#     confirm = confirm.select { |i| i > known_after } if known_after
#     return if confirm.nil? || confirm.empty?
#
#     @confirmed[:street_name] = confirm
#     confirm.map { |c| @confirmed[:unit].delete c } if @confirmed[:unit] # Remove it from unit if it's in there
#   end
#
#   def confirm_highway_street_name
#     return false unless highway_street?
#
#     # find where it says highway, check if the next one is a number
#     label_position = confirmed_map(%i[street_label]).select { |sep| sep.text.include?('hwy') || sep.text.include?('highway') }.last.position
#     after_label = @sep_map[label_position + 1]
#     return false unless after_label.text.has_digits?
#
#     @confirmed[:street_name] = [after_label.position]
#     # If it's a number it was probably picked up as a unit
#     if @confirmed[:unit]&.include?(after_label.position)
#       @confirmed[:unit].length == 1 ? @confirmed = @confirmed.except(:unit) : @confirmed[:unit].delete(after_label.position)
#     end
#     true
#   end
#
#   def confirm_city
#     # TODO: Select everything within the same comma_block
#     known_after = confirmed_positions(%i[street_label street_direction]).max
#     known_before = confirmed_positions(%i[postal country state]).min
#
#     confirm = potential(:city).reject { |i| confirmed_positions.include? i }
#     confirm = confirm.select { |i| i < known_before } if known_before
#     confirm = confirm.select { |i| i > known_after } if known_after
#     @confirmed[:city] = confirm if confirm && !confirm.empty?
#   end
#
#   ### Methods for finding specific things about an address
#
#   def direction_touching_number?
#     return false unless @confirmed[:street_direction] && @confirmed[:street_number]
#
#     @confirmed[:street_direction].min - 1 == @confirmed[:street_number].max
#   end
#
#   def label_touching_number?
#     return false unless @confirmed[:street_label] && @confirmed[:street_number]
#
#     @confirmed[:street_label].min - 1 == @confirmed[:street_number].max
#   end
#
#   def highway_street?
#     labels = confirmed_map(%i[street_label]).map(&:text)
#     labels.include?('hwy') || labels.include?('highway')
#   end
#
#   def set_parts
#     return if @confirmed.keys.length < 3
#
#     @parts = { orig: @input }
#     @confirmed.each do |label, indexes|
#       @parts[label] = indexes.map { |i| NYAConstants::STANDARDIZE_ALL[@sep_map[i].text] || @sep_map[i].text }.join(' ')
#     end
#
#     @parts.each do |label, part|
#       @parts[label] = NYAConstants::STANDARDIZE_ALL[part] || part
#     end
#
#     unfound = (0...@sep_map.length).to_a - confirmed_positions
#     @parts[:bus] = unfound.map { |i| @sep_map[i] }
#     assume_parts
#     cleanup_parts
#   end
#   ### ASSUME PARTS THAT WERE NOT FOUND
#   # Based on what's in the bus
#   def assume_parts
#     # Check if unit is in street number
#     # 1) If street number has - or / unit is the smallest length
#     # 2) If street number is all nums except 1 letter, letter is unit
#     search_for_unit_in_street_num if @parts[:unit].nil? && @parts[:street_number]
#
#     # Search for the street_name elsewhere
#     search_for_street_name if @parts[:street_name].nil?
#
#     # set puerto rico as the state
#     @parts[:state] = @parts[:country] if @parts[:state].nil? && @parts[:country] == 'pr'
#
#     return if @parts[:bus].nil? || @parts[:bus].empty?
#
#     search_for_label_in_bus if @parts[:street_label].nil?
#     search_for_state_in_bus if @parts[:state].nil?
#
#   end
#
#   def search_for_street_name
#     # Check if street name got picked up as direction
#     if @parts[:street_direction]
#       return if search_for_name_in_direction
#     end
#
#     if @parts[:street_label]
#       return if search_for_saint_name # Check if street was a st->Saint
#       return if search_for_name_in_label # Check if street name was in street_label
#     end
#
#     return if guess_name_from_bus
#     overwrite_direction_as_name
#   end
#
#   def search_for_unit_in_street_num
#     if @parts[:street_number].letter_count == 1
#       @parts[:unit] = @parts[:street_number].strip_digits
#       @parts[:street_number] = @parts[:street_number].strip_letters
#       return
#     end
#
#     sn = @parts[:street_number].split(%r{[-/]}, 2)
#     return unless sn.length == 2
#
#     unit = sn.min { |x, y| x.size <=> y.size }
#     unit_pos = @parts[:street_number].index(unit) - 2
#     @parts[:unit] = unit.strip
#     after = @parts[:street_number][unit_pos + unit.length + 3..]
#     before = unit_pos.negative? ? '' : @parts[:street_number][0..unit_pos]
#     @parts[:street_number] = before.to_s + after.to_s
#   end
#
#   def search_for_name_in_direction
#     spl = @parts[:street_direction].split
#     return false unless spl.length > 1
#
#     chosen = spl.first
#     @parts[:street_name] = chosen
#     @parts[:street_direction] = @parts[:street_direction].sub(chosen, '').strip
#
#     # Check to see if there's anything on the bus
#     potential = @parts[:bus].select { |sep| sep.from_position.include? :street_name }.first
#     return false unless potential
#     return false unless @sep_map[potential.position - 1].text.include? chosen
#
#     @parts[:street_name] << " #{potential.text}"
#     @parts[:bus] = @parts[:bus][1..]
#     # @parts = @parts.except(:bus) if @parts[:bus].empty?
#     true
#   end
#
#   def search_for_name_in_label
#     spl = @parts[:street_label].split
#     return false unless spl.length > 1
#
#     chosen = spl.first
#     @parts[:street_name] = chosen
#     @parts[:street_label] = @parts[:street_label].sub(chosen, '').strip
#   end
#
#   def search_for_saint_name
#     # Saint must come before the street_name
#     return false unless @parts[:street_label].include? 'st'
#     return false unless @parts[:bus] && !@parts[:bus].empty?
#
#     potential_name = @parts[:bus].first
#     sep_st = @confirmed[:street_label].map { |pos| @sep_map[pos] }.select { |sep| sep.text.include? 'st' }.first
#     # Saint must be before the street name
#     return false unless sep_st.position + 1 == potential_name.position
#
#     # Remove st from label and add to street name
#     @parts[:street_label] = @parts[:street_label].sub('st', '').strip
#     @parts = @parts.except(:street_label) if @parts[:street_label].empty?
#     @parts[:street_name] = "st #{@parts[:bus].first.text}"
#     true
#   end
#
#   def guess_name_from_bus
#     return false unless @parts[:bus]
#
#     potential = @parts[:bus].select { |sep| sep.from_position.include? :street_name }
#     return false if potential.empty?
#
#     @parts[:street_name] = potential.first.text
#     true
#   end
#
#   def overwrite_direction_as_name
#     return false unless @parts[:street_direction]
#
#     spl = @parts[:street_direction].split
#     @parts[:street_name] = spl.first
#     @parts[:street_direction] = spl[1..].join
#     @parts = @parts.except(:street_direction) if @parts[:street_direction].empty?
#     true
#   end
#
#   def search_for_label_in_bus
#     potential = @parts[:bus].select { |sep| sep.from_pattern.include?(:street_label) }
#     return if potential.empty?
#
#     @parts[:street_label] = potential.map(&:text).join
#     potential.map { |p| @parts[:bus].delete p }
#   end
#
#   def search_for_state_in_bus
#     # TODO: fix test_pre_unit
#     potential = @parts[:bus].select { |sep| sep.from_position.include?(:state) }
#     return if potential.empty?
#
#     @parts[:state] = potential.map(&:text).join
#     potential.map { |p| @parts[:bus].delete p }
#   end
#
#   ### PARTS CLEANING
#   # ###
#
#   def cleanup_parts
#     @parts[:postal] = @parts[:postal].gsub(/o|O/, '0') if @parts[:postal]
#     NYAConstants::UNIT_DESCRIPTORS.each { |desc| @parts[:unit] = @parts[:unit].gsub(desc, '').strip } if @parts[:unit]
#
#     remove_duplicate_direction if @parts[:street_name] && @parts[:street_direction]
#
#     # If there was a unit but no name, make the name the unit
#     # TODO: make sure unit comes after street number?
#     if @parts[:unit] && @parts[:street_name].nil?
#       @parts[:street_name] = @parts[:unit]
#       @parts[:unit] = nil
#     end
#   end
#
#   # North Main St N -> Main St N
#   def remove_duplicate_direction
#     spl = @parts[:street_name].split
#     return unless @parts[:street_direction].include? spl.first
#
#     @parts[:street_name] = spl[1..].join
#   end
# end
