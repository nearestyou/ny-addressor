if ENV['LOCAL_DEPENDENCIES']
  load 'lib/ny-us-address.rb'
  load 'lib/ny-ca-address.rb'
  load 'lib/ny-non-address.rb'
  load 'lib/identifier.rb'
  load 'lib/constants.rb'
  load 'lib/extensions.rb'
  load 'lib/addressor_utils.rb'
else
  require 'ny-us-address.rb'
  require 'ny-ca-address.rb'
  require 'ny-non-address.rb'
  require 'identifier.rb'
  require 'constants.rb'
  require 'extensions.rb'
  require 'addressor_utils.rb'
end

class NYAddressor
  attr_accessor :input, :region, :addressor

  def initialize(input)
    if input.nil? or input.length < 4
      set_region_addressor
      return
    end
    @input = input
    @clean = input&.gsub(',',' ')&.delete("'")&.downcase&.split(' ')
    potential_region = []
    potential_region << :US if potential_us
    potential_region << :CA if potential_ca

    if potential_region.length == 1
      @region = potential_region[0]
    elsif potential_region.length > 1
      @region = :CA
    end
    set_region_addressor
  end

  def potential_us
    return 1 if (NYAConstants::US_DESCRIPTORS & (@clean&.map(&:downcase) || [])).count > 0
    down = @input.downcase
    return 2 if NYAConstants::CB_ISLAND_NAMES.map{|island| down.include?(island)}.any?
    return false
  end

  def potential_ca
    typified = AddressorUtils.typify(@input)
    typified.include?('=|= |=|') or typified.include?('=|=|=|')
  end

  def set_region_addressor
    case @region
    when :US
      @addressor = NYUSAddress.new(@input)
      @addressor = NYNONAddress.new if (@addressor.parts.nil? or @addressor.parts.keys.count < 1)
    when :CA
      @addressor = NYCAAddress.new(@input)
      @addressor = NYNONAddress.new if (@addressor.parts.nil? or @addressor.parts.keys.count < 1)
    else
      ### Temporarily routing through US !

      @addressor = NYNONAddress.new
      # @addressor = NYUSAddress.new(@input)
    end
  rescue Exception => e
    @addressor = NYNONAddress.new
  end

  ## Manually inheriting methods from region specific addressor
  def construct(opts = {}); @addressor.construct(opts); end
  def hash; @addressor.hash; end
  def hash99999; @addressor.hash99999; end
  def unitless_hash; @addressor.unitless_hash; end
  def sns; @addressor.sns; end
  def comp(nya, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(@addressor.parts, nya.addressor.parts, comparison_keys); end

  def self.string_inclusion(str1, str2, numeric_failure = false); AddressorUtils.string_inclusion(str1, str2, numeric_failure); end
  def self.determine_state(state_name, postal_code = nil); AddressorUtils.determine_state(state_name, postal_code); end
  #def self.comp(parts1, parts2, comparison_keys = [:street_number, :street_name, :postal_code]); AddressorUtils.comp(parts1, parts2, comparison_keys); end
  def self.comp(*args); AddressorUtils.comp(*args); end

end
