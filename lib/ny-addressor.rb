#load 'lib/ny-us-address.rb'
#load 'lib/ny-ca-address.rb'
#load 'lib/ny-non-address.rb'
#load 'lib/identifier.rb'

class NYAddressor
  attr_accessor :input, :region, :addressor

  def initialize(input)
    if input.nil?
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
    return (NYAConstants::US_DESCRIPTORS & (@clean&.map(&:downcase) || [])).count > 0
    #state = (NYAConstants::US_DESCRIPTORS & @clean.map(&:downcase)).count > 0
    #zip = !@clean.last.has_letters? # what if there's no ZIP? What if there's a country?
    #state and zip
  end

  def potential_ca
    typified = AddressorUtils.typify(@input)
    typified.include?('=|= |=|') or typified.include?('=|=|=|')
  end

  def set_region_addressor
    case @region
    when :US
      @addressor = NYUSAddress.new(@input)
    when :CA
      @addressor = NYCAAddress.new(@input)
    else
      @addressor = NYNONAddress.new
    end
  end

  ## Manually inheriting methods from region specific addressor
  def construct(opts = {}); @addressor.construct(opts); end
  def hash; @addressor.hash; end
  def hash99999; @addressor.hash99999; end
  def unitless_hash; @addressor.unitless_hash; end
  def sns; @addressor.sns; end

  def self.string_inclusion(str1, str2, numeric_failure = false); AddressorUtils.string_inclusion(str1, str2, numeric_failure); end
  def self.determine_state(state_name, postal_code = nil); AddressorUtils.determine_state(state_name, postal_code); end

end
