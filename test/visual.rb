# frozen_string_literal: true
require_relative '../lib/ny-addressor'

if ARGV.empty?
  puts "Enter address to disect"
  exit
end

inp = ARGV.join(' ')
nya = NYAddressor::Addressor.new(inp)
puts "Region not detected" unless nya.region
puts nya.debug
puts nya.sns
puts nya.construct
puts nya.hash
