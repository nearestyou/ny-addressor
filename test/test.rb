# frozen_string_literal: true

load 'lib/ny_addressor.rb'
class Tester
  def initialize(adr)
    nya = NYAddressor.new(adr)
    # nya.sep_map.map { |m| puts m.to_s << "\n" }
    puts nya.parts
    puts nya.sns, nya.construct, nya.hash
    puts "\n\n\n"
  end
end

# Tester.new('10799 Sundance BLVD N, Maple Grove, MN, 55369')
# Tester.new('6837 Big Lake BLVD NW Suite 737 Otsego MN 55388')
# Tester.new('655 Forest Ave, Lake Forest, IL 60045')
# Tester.new('6075 U.S. Hwy 17-92 N, Davenport, FL 33896, United States')
# Tester.new('1600 First Ave, St. Washington, D.C., 20500')
# Tester.new('1600 First Ave, St Washington, DC, 20500')
# Tester.new('89 Trinity Dr, Moncton, NB E1G 2J7')
# Tester.new('89 Trinity Dr, Moncton NB E1G 2J7, Canada')
# Tester.new('1600 North Pennsylvania (at 16th) Ave, Washington, DC, 20500')
# Tester.new('1600 Pennsylvania Ave, Washington DC')
# Tester.new('1600 Pennsylvania Ave, Washington, DC 99999')
# Tester.new('5850, boul. Jean XXIII, Trois-Rivières, QC, G8Z 4B5')
# Tester.new('602 21st r  NW, portland,, or 97209')
# Tester.new('1600 Pennsylvania Ave, Washington, DC 20500, Washington, DC 20500')
# Tester.new('1600 Pennsylvania Ave, Washington DC, DC 20500')
# Tester.new('1600 Pennsylvania Ave, Washington, DC, DC 20500')
# Tester.new('1600 Pennsylvania Ave, Washington, DC 20500')
# Tester.new('13322 West Airport Boulevard, Sugar Land, TX 77478')
# Tester.new('13322 Airport Blvd W, Sugar Land, TX 77478')
# Tester.new('13322 West Airport Boulevard, Sugar Land, TX 77478-9898')
# Tester.new('333 Main Express way,AURORA,OR,97002')
# Tester.new('72070 BC-3, Cawston, BC V0X 1C2, Canada')
# Tester.new('1500 Bennsylvania Ave, Washington, ON H0H 0H0')
# Tester.new('1500 Bennsylvania Ave, Washington, ON H0H0H0')
# Tester.new('15355 24 Ave,700 (at Peninsula Village), Surrey BC V4A 2H9, Canada')
# Tester.new('15355 24 Ave,#700 (at Peninsula Village), Surrey BC V4A 2H9, Canada')
Tester.new('1507 10TH AVE, SEATTLE, WA 98120')
Tester.new('1505 & 1507 10TH AVE, SEATTLE, WA 98120')
Tester.new('1505&1507 10TH AVE, SEATTLE, WA 98120')
