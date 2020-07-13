require 'digest'
require 'byebug'
load 'lib/constants.rb'
load 'lib/identifier.rb'

class NYAddress
  attr_accessor :monitor, :str, :orig, :typified, :sep, :bus, :sep_map, :sep_comma, :idr, :parts

  def initialize(str)
    @monitor = false
    if not str.nil?
      @orig = str # to keep an original
      @str = str
      @idr = NYIdentifier.new(self)
      identify
    end
  end

  def identify
    identification = @idr.identifications
    @sep = identification[:sep]
    @sep_map = identification[:sep_map]
    @sep_comma = identification[:sep_comma]
    @bus = identification[:sep_map]
    @locale = identification[:locale]
    @parts = identification[:parts]
  end

  def reset_str(str = @orig)
    @str = str
  end

  def typify
    @typified = AddressorUtils.typify(@str)
  end

  def construct(opts = {})
    opts = {include_unit: true}.merge(opts)
    addr = sns
    if addr.length > 0
      opts[:include_unit] ? addr << @parts[:unit].to_s : nil
    end
    addr
  end

  def hash
    return nil if @parts.nil?
    Digest::SHA256.hexdigest(construct)[0..23]
  end

  def hash99999 # for searching by missing/erroneous ZIP
    return nil if @parts.nil?
    Digest::SHA256.hexdigest(construct[0..-6] + "99999")[0..23]
  end

  def unitless_hash
    return nil if @parts.nil?
    Digest::SHA256.hexdigest(construct({include_unit: false}))[0..23]
  end

  def sns
    if @parts[:street_number].length > 0 and @parts[:street_name].length > 0 and @parts[:state].length > 0
      return "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:state]}".delete(' ').delete('-')
    else
      return ""
    end
  end

  def eq(address_parts, display = false)
    # debugger
    return nil if @parts.nil?

    return false if @parts[:street_number].to_s.downcase != address_parts[:street_number].to_s.downcase
    return false if @parts[:street_name].to_s.downcase != address_parts[:street_name].to_s.downcase
    return false if @parts[:street_label].to_s.downcase != address_parts[:street_label].to_s.downcase and not @parts[:street_label].nil? and not address_parts[:street_label].nil?
    return false if @parts[:street_direction].to_s.downcase != address_parts[:street_direction].to_s.downcase and not @parts[:street_direction].nil? and not address_parts[:street_direction].nil?
    return false if @parts[:unit].to_s.downcase.reverse[0,3] != address_parts[:unit].to_s.downcase.reverse[0,3] and not @parts[:unit].nil? and not address_parts[:unit].nil?
    return false if @parts[:city].to_s.downcase != address_parts[:city].to_s.downcase
    return false if @parts[:state].to_s.downcase != address_parts[:state].to_s.downcase
    return false if @parts[:postal_code].to_s.downcase[0,5] != address_parts[:postal_code].to_s.downcase[0,5] and not @parts[:postal_code].nil? and not address_parts[:postal_code].nil?
    return false if @parts[:country].to_s.downcase != address_parts[:country].to_s.downcase and not @parts[:country].nil? and not address_parts[:country].nil?

    return true
  end

  def comp(parsed_address)
    return 0 if @parts.nil?
    return 0 if parsed_address.nil?
    sims = 0
    sims += 1 if @parts[:street_number] == parsed_address[:street_number]
    sims += 1 if @parts[:street_name] == parsed_address[:street_name]
    sims += 1 if @parts[:postal_code] == parsed_address[:postal_code]
    sims
  end

  def ordinalize_street(street)
    {
      'first' => '1st', 'second' => '2nd', 'third' => '3rd', 'fourth' => '4th', 'fifth' => '5th', 'sixth' => '6th', 'seventh' => '7th', 'eighth' => '8th', 'ninth' => '9th', 'tenth' => '10th', 'eleventh' => '11th', 'twelfth' => '12th'
    }[street] || street
  end

  def self.string_inclusion(str1, str2, numeric_failure = false)
    strs = [ str1.downcase.gsub(/[^a-z0-9]/, ''), str2.downcase.gsub(/[^a-z0-9]/, '') ].sort_by{|str| str.length}
    case
    when strs.last.include?(strs.first)
      return 1
    else
      if numeric_failure
        better_match = 0
        short_length = strs.first.length
        long_length = strs.last.length

        (short_length - 1).downto(1) do |n|
          0.upto(short_length - n) do |i|
            better_match = [n, better_match].max if strs.last.include?(strs.first[i..(i+n-1)])
          end
        end

        (long_length - 1).downto(1) do |n|
          break if n <= better_match
          0.upto(long_length - n) do |i|
            better_match = [n, better_match].max if strs.first.include?(strs.last[i..(i+n-1)])
          end
        end

        return better_match.to_f / short_length
      else
        return 0
      end
    end
  end

  def self.determine_state(state_name, zip = nil)
    if zip
    else
      return NYAConstants::US_STATES[state_name] if NYAConstants::US_STATES[state_name]
      return NYAConstants::CA_PROVINCES[state_name] if NYAConstants::CA_PROVINCES[state_name]
      return 'ER'
    end
  end

end
