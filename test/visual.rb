# frozen_string_literal: true

ENV['LOCAL_DEPENDENCIES'] = 'true'
load 'lib/ny-addressor.rb'

inp = '246 North Hyland Ave, Ames, IA'

nya = NYAddressor.new(inp)
nya.sep_map.each { |sep| puts sep }
puts nya.hash, nya.unitless_hash, nya.hash99999
puts nya.sns, nya.construct, nya.parts
