#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative '../lib/ny-addressor'

if ARGV.empty?
  puts "Enter address to disect"
  exit 1
end

inp = ARGV.join(' ')
nya = NYAddressor.process(inp)
puts nya.normalized
nya.parts.each do |k, v|
  puts "  #{k.to_s.ljust(16)} -> #{v.inspect}"
end
puts nya.expanded_variants
