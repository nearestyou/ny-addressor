load 'lib/ny-address.rb'


class NYAddressor
  attr_accessor :input, :output

  def initialize(input)
    @input = input

    if input.is_a? String
      @output = NYAddress.new(input).parts
    elsif input.is_a? Array
      @output = []
      input.each do |address|
        @output.push NYAddress.new(address).parts
      end
    end
  end
end
