# frozen_string_literal: true
require_relative '../lib/ny-addressor'

inp = '&#34;N72 W13400 LUND LN SUITE&#34;,MENOMONEE FALLS,WI,53051'
inp = '26059 MISSION BLVD.,HAYWARD,CA,94544'
inp = '14351 104 Ave, Surrey, BC V3T 1Y1, Canada'
inp = '1310 Ashford Ave San Juan PR 907'
inp = 'Carretera Estatal 115, Km. 26.9 Bo. Tablonal AGUADA PR 00602'
inp = 'E-9 Av. Luis Muñoz Marín, Caguas, 00725, Puerto Rico'
inp = '161 Victoria St N, Saint Paul, MN 55104, United States'
inp = '1102 Larpenteur, Saint Paul, MN, United States'

nya = NYAddressor::Addressor.new(inp)
puts nya.debug
puts nya.sns
puts nya.construct
puts nya.hash
