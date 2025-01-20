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
inp = '4051 Broadway, New York, NY 10032, United States'
inp = '2656 Parkway, Pigeon Forge, TN 37863, United States'
inp = '4127 6 Street NE, Calgary AB T2E, Canada'
inp = '128 Middle Road, Warwick, Bermuda WK04, United States'
inp = '21 Rue du Mesnil, 50400 Granville, FR'

nya = NYAddressor::Addressor.new(inp)
puts nya.debug
puts nya.sns
puts nya.construct
puts nya.hash
