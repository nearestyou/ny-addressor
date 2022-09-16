# frozen_string_literal: true

# gem build ny-addressor.gemspec
# bundle info ny-addressor

ENV['LOCAL_DEPENDENCIES'] = 'true'
load 'lib/ny-addressor.rb'

inp = 'UNIT 23 11151 HORSESHOE WAY, RICHMOND BC, V7A4S5'
inp = 'B2 - 15562 24TH AVENUE, SURREY BC, V4A2J5'
inp = '150 - 19288 22ND AVENUE, SURREY BC, V3S3S9'

nya = NYAddressor.new(inp)
nya.sep_map.each { |sep| puts sep }
puts nya.to_s
# puts nya.hash, nya.unitless_hash, nya.hash99999
# puts nya.sns, nya.construct, nya.parts
