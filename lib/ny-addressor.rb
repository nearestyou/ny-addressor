load 'lib/ny-us-address.rb'
# load 'lib/constants.rb'


class NYAddressor
  attr_accessor :input, :output, :region

  def initialize(input)
    @input = input
    @clean = input.delete(',').delete("'").downcase.split(' ')
    potential_region = []
    potential_region << :US if potential_us

    if potential_region.length == 1
      @region = potential_region[0]
      # puts "#{input} failed"
    # else
    #   puts "#{input} failed"
    end
  end

  def potential_us
    state = false
    zip = false
    NYAConstants::US_DESCRIPTORS.each { |desc| @clean.each { |word| state = true if word == desc } }
    zip = true if not @clean.last.has_letters?
    state and zip
  end
end
