# frozen_string_literal: true

# gem build ny-addressor.gemspec
# bundle info ny-addressor

ENV['LOCAL_DEPENDENCIES'] = 'true'
load 'lib/ny-addressor.rb'

inp = '&#34;N72 W13400 LUND LN SUITE&#34;,MENOMONEE FALLS,WI,53051'
inp = '26059 MISSION BLVD.,HAYWARD,CA,94544'
inp = '14351 104 Ave, Surrey, BC V3T 1Y1, Canada'
inp = '1310 Ashford Ave San Juan PR 907'
inp = 'Carretera Estatal 115, Km. 26.9 Bo. Tablonal AGUADA PR 00602'
inp = 'E-9 Av. Luis Muñoz Marín, Caguas, 00725, Puerto Rico'

nya = NYAddressor.new(inp)
nya.sep_map.each { |sep| puts sep }
puts nya.to_s
puts 'hash requires street name, number, & state'
# puts nya.hash, nya.unitless_hash, nya.hash99999
# puts nya.sns, nya.construct, nya.parts
