require 'digest'
#require 'byebug'
#load 'lib/constants.rb'
#load 'lib/identifier.rb'

class NYUSAddress
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
    @parts = identification[:parts] if identification[:parts].size > 0
  end

  def reset_str(str = @orig)
    @str = str
  end

  def typify
    @typified = AddressorUtils.typify(@str)
  end

  def construct(opts = {})
    opts = {include_unit: true, include_label: true, include_dir: true, include_postal: true}.merge(opts)
    return nil if @parts.nil?
    addr = "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:city]}#{@parts[:state]}"
    return nil if addr.length < 2

    opts[:include_unit] ? addr << @parts[:unit].to_s : nil
    opts[:include_label] ? addr << @parts[:street_label].to_s : nil
    opts[:include_dir] ? addr << @parts[:street_direction].to_s : nil
    postal_code = @parts[:postal_code] || '99999'
    opts[:include_postal] ? addr << postal_code.to_s[0..4] : nil
    addr.delete(' ').delete('-').downcase
  end

  def hash
    key = construct
    return nil if key.nil?
    Digest::SHA256.hexdigest(key)[0..23]
  end

  def unitless_hash
    key = construct(opts={include_unit: false})
    return nil if key.nil?
    Digest::SHA256.hexdigest(key)[0..23]
  end

  def hash99999 # for searching by missing/erroneous ZIP
    return nil if @parts.nil?
    Digest::SHA256.hexdigest(construct[0..-6] + "99999")[0..23]
  end

  def sns
    begin
      if @parts[:street_number].length > 0 and @parts[:street_name].length > 0 and @parts[:state].length > 0
        return "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:state]}".delete(' ').delete('-')
      else
        return ""
      end
    rescue
      return ""
    end
  end

  def eq(address_parts, display = false)
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

  def ordinalize_street(street)
    {
      'first' => '1st', 'second' => '2nd', 'third' => '3rd', 'fourth' => '4th', 'fifth' => '5th', 'sixth' => '6th', 'seventh' => '7th', 'eighth' => '8th', 'ninth' => '9th', 'tenth' => '10th', 'eleventh' => '11th', 'twelfth' => '12th'
    }[street] || street
  end

end
