load 'lib/ny-us-address.rb'
load 'lib/ny-non-address.rb'
load 'lib/identifier.rb'
# load 'lib/constants.rb'


class NYAddressor
  attr_accessor :input, :output, :region, :addressor

  def initialize(input)
    @input = input
    @clean = input.delete(',').delete("'").downcase.split(' ')
    potential_region = []
    potential_region << :US if potential_us
    potential_region << :CA if potential_ca

    if potential_region.length == 1
      @region = potential_region[0]
      # puts "#{input} failed"
    # else
    #   puts "#{input} failed"
    end
    set_region_addressor
  end

  def potential_us
    state = false
    zip = false
    NYAConstants::US_DESCRIPTORS.each { |desc| @clean.each { |word| state = true if word == desc } }
    zip = true if not @clean.last.has_letters?
    state and zip
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
      @addressor = NYUSAddress.new(@input)
    else
      @addressor = NYNONAddress.new
    end
  end

  ## Manually inheriting methods from region specific addressor
  def construct(opts = {}); @addressor.construct(opts); end
  def hash; @addressor.hash; end
  def hash99999; @addressor.hash99999; end
  def unitlesshash; @addressor.unitlesshash; end
  def sns; @addressor.sns; end
  
end
