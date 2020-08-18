# if ENV['LOCAL_DEPENDENCIES']
  load 'lib/identifier.rb'
  load 'lib/us-identifier.rb'
  load 'lib/ca-identifier.rb'
  load 'lib/constants.rb'
  load 'lib/extensions.rb'
  load 'lib/addressor_utils.rb'
# else
#   require 'us-identifier.rb'
#   require 'ca-identifier.rb'
#   require 'identifier.rb'
#   require 'constants.rb'
#   require 'extensions.rb'
#   require 'addressor_utils.rb'
# end
require 'digest'

class NYAddressor
  attr_accessor :input, :region, :identity, :parts

  def initialize(input)
    if input.nil? or input.length < 4
      @region = :NO
      return
    end
    @input = input
    @clean = input&.gsub(',',' ')&.delete("'")&.downcase&.split(' ')
    @region = set_region
    @identity = identify
    @parts = @identity.parts if @identity
  end

  def identify
    case @region
    when :US
      return USIdentifier.new(@input)
    when :CA
      return CAIdentifier.new(@input)
    else
      return nil
    end
  end

  def set_region
    regions = []
    regions << :CA if potential_ca
    regions << :US if potential_us
    case regions.length
    when 0
      return :NO
    when 1
      return regions[0]
    else
      return elim_region(regions)
    end
  end

  def potential_us
    return (NYAConstants::US_DESCRIPTORS & (@clean&.map(&:downcase) || [])).count > 0
  end

  def potential_ca
    typified = AddressorUtils.typify(@input)
    typified.include?('=|= |=|') or typified.include?('=|=|=|')
  end

  def elim_region(regions)
    #put some logic here to determine country possibly???

    regions[0] #this is temporary !
  end

  def construct(opts = {})
    opts = {include_unit: true, include_label: true, include_dir: true, include_postal: true}.merge(opts)
    return nil if @parts.nil?

    addr = "#{@parts[:street_number]}#{@parts[:street_name]}#{@parts[:city]}#{@parts[:state]}"
    opts[:include_unit] ? addr << @parts[:unit].to_s : nil
    opts[:include_label] ? addr << @parts[:street_label].to_s : nil
    opts[:include_dir] ? addr << @parts[:street_direction].to_s : nil
    postal_code = @parts[:postal_code] || '99999'
    opts[:include_postal] ? addr << postal_code.to_s : nil
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


  def comp(nya, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(@parts, nya.parts, comparison_keys); end

  def self.string_inclusion(str1, str2, numeric_failure = false); AddressorUtils.string_inclusion(str1, str2, numeric_failure); end
  def self.determine_state(state_name, postal_code = nil); AddressorUtils.determine_state(state_name, postal_code); end
  #def self.comp(parts1, parts2, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(parts1, parts2, comparison_keys); end
  def self.comp(*args); AddressorUtils.comp(*args); end

end
