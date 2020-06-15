require 'digest'
load 'lib/constants.rb'
load 'lib/identifier.rb'

class NYAddressor
  attr_accessor :monitor, :str, :orig, :typified, :sep, :bus, :sep_map, :idr

  def initialize(str)
    @monitor = false
    @orig = str # to keep an original
    @str = str
    @idr = NYIdentifier.new(self)
    identify
  end

  def identify
    identification = @idr.identifications
    @sep = identification[:sep]
    @sep_map = identification[:sep_map]
    @bus = identification[:sep_map]
    @locale = identification[:locale]
  end

  def reset_str(str = @orig)
    @str = str
  end

  def typify
    @typified = AddressorUtils.typify(@str)
  end

  def construct(opts = {})
  end

  def hash
    return nil if @parsed.nil?
    Digest::SHA256.hexdigest(construct)[0..23]
  end

  def hash99999 # for searching by missing/erroneous ZIP
    return nil if @parsed.nil?
    Digest::SHA256.hexdigest(construct[0..-6] + "99999")[0..23]
  end

  def unitless_hash
    return nil if @parsed.nil?
    Digest::SHA256.hexdigest(construct({exclude_unit: true}))[0..23]
  end

  def sns
    @parsed ? ([@bus[:street_number] || @parsed.number || '',@parsed.street || '',@bus[:state] || @parsed.state].join('')&.downcase&.gsub('-','') || '') : ''
  end

  def eq(parsed_address, display = false)
    return nil if @parsed.nil?
    # for displaying errors (display ? puts(parsed_address, @parsed) : false)
    return false if @parsed.number != parsed_address.number
    return false if @parsed.postal_code != parsed_address.postal_code
    return false if @parsed.street != parsed_address.street
    return false if @parsed.unit != parsed_address.unit
    return false if @parsed.city != parsed_address.city
    return false if @parsed.street_type != parsed_address.street_type
    return true
  end

  def comp(parsed_address)
    return 0 if @parsed.nil?
    return 0 if parsed_address.nil?
    sims = 0
    sims += 1 if @parsed.number == parsed_address.number
    sims += 1 if @parsed.street == parsed_address.street
    sims += 1 if @parsed.postal_code == parsed_address.postal_code
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
      return US_STATES[state_name] if US_STATES[state_name]
      return CA_PROVINCES[state_name] if CA_PROVINCES[state_name]
      return 'ER'
    end
  end

end
