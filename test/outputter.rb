require 'csv'
require_relative '../lib/ny-addressor'
require_relative '../lib/ny-addressor/address_field'

input = File.join(Dir.home, 'Downloads', 'tindle Germany test.csv')
output = File.join(Dir.home, 'Downloads', 'germany addressored.csv')
fields = NYAddressor::AddressField.constants


with_hash = []
without_hash = []
header = ['original', 'hash'] + fields.map(&:to_s)

CSV.foreach(input, headers: false) do |row|
  address = row[1..].join(', ')
  nya = NYAddressor.new(address)
  address_data = { original: address, hash: nya.hash }.merge(nya.parts)
  ordered_data = header.map { |field| address_data[field.downcase.to_sym] }
  if nya.hash
    with_hash << ordered_data
  else
    without_hash << ordered_data
  end
end

CSV.open(output, 'w', headers: true) do |csv_out|
  header = ['original', 'hash'] + fields.map(&:to_s)
  csv_out << header

  without_hash.each do |row|
    csv_out << row
  end

  with_hash.each do |row|
    csv_out << row
  end
end
