# frozen_string_literal: true

# gem build ny-addressor.gemspec

ENV['LOCAL_DEPENDENCIES'] = 'true'
load 'lib/ny-addressor.rb'

inp = '5728 111 St NW, Edmonton AB T6H 3G1, Canada'

nya = NYAddressor.new(inp)
nya.sep_map.each { |sep| puts sep }
puts nya.to_s
# puts nya.hash, nya.unitless_hash, nya.hash99999
# puts nya.sns, nya.construct, nya.parts
