# frozen_string_literal: true

# gem build ny-addressor.gemspec

ENV['LOCAL_DEPENDENCIES'] = 'true'
load 'lib/ny-addressor.rb'

inp = '2343 E Highway 101, Port Angeles, WA 98362, United States'

nya = NYAddressor.new(inp)
nya.sep_map.each { |sep| puts sep }
puts nya.hash, nya.unitless_hash, nya.hash99999
puts nya.sns, nya.construct, nya.parts
