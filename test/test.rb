load 'lib/ny-addressor.rb'

class Tester
  def initialize(adr)
    nya = NYAddressor.new(adr)
    # nya.sep_map.map { |m| puts m.to_s << "\n" }
    puts nya.parts
    puts nya.sns, nya.construct, nya.hash
    puts "\n\n\n"
  end
end

Tester.new('8320-100 Litchford Rd, Raleigh, NC 27602, United States')
