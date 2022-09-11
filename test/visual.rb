# frozen_string_literal: true

# gem build ny-addressor.gemspec
# bundle info ny-addressor

ENV['LOCAL_DEPENDENCIES'] = 'true'
load 'lib/ny-addressor.rb'

inp = '260 Court St Unit 6, Middlebury, VT 05753, USA'

nya = NYAddressor.new(inp)
nya.sep_map.each { |sep| puts sep }
puts nya.to_s
# puts nya.hash, nya.unitless_hash, nya.hash99999
# puts nya.sns, nya.construct, nya.parts
