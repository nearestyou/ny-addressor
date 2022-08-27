# frozen_string_literal: true

load 'lib/ny_addressor.rb'
class Tester
  def initialize(adr)
    nya = NYAddressor.new(adr)
    nya.sep_map.map { |m| puts m }
    puts "\n\n\n"

    puts adr
    nya.confirmed.each do |key, value|
      puts "#{key}: #{value.map { |i| nya.sep_map[i].text }}"
    end
  end
end

# Tester.new('10799 Sundance BLVD N, Maple Grove, MN, 55369')
# Tester.new('6837 Big Lake BLVD NW Suite 737 Otsego MN 55388')
# Tester.new('655 Forest Ave, Lake Forest, IL 60045')
Tester.new('6075 U.S. Hwy 17-92 N, Davenport, FL 33896, United States')
