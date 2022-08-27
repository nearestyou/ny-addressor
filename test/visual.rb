# frozen_string_literal: true

load 'lib/ny_addressor.rb'
class Tester
  def initialize(file)
    File.open(file, 'r') do |f|
      f.each_line do |line|
        puts line
        nya = NYAddressor.new(line)
        nya.confirmed.each do |key, value|
          puts "#{key}: #{value.map { |i| nya.sep_map[i].text }}"
        end
        puts "\n\n\n"
      end
    end
  end
end

Tester.new('test/adrs.txt')
