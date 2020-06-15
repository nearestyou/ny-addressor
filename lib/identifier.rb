load 'lib/addressor_utils.rb'
load 'lib/constants.rb'

class NYIdentifier
attr_accessor :str, :sep, :sep_map, :locale, :bus

def initialize(nya = nil)
  if @nya = nya
    clean_string
  end
  @bus = {}
  self
end

def clean_string
  @str ||= @nya.str
  while @str.include?('(') and @str.include?(')')
    first_open = @str.index('(')
    first_close = @str.index(')')
    @bus[:parentheses] ||= []
    @bus[:parentheses] << @str[first_open+1..first_close-1]
    @str = @str[0..first_open-1] + @str[first_close+1..-1]
  end
  @str = @str.gsub(',',' ').gsub(/\s+/,' ')
end

def identifications
  identify
  { sep: @sep, sep_map: @sep_map, locale: @locale, bus: @bus }
end

def identify
  separate
  create_sep_map
  identify_all_by_pattern
  identify_all_by_location
  consolidate_identity_options
end

def create_sep_map
  @sep_map = @sep.map{|part| {text: part, down: part.gsub('.','').downcase, typified: AddressorUtils.typify(part)} }
end

def separate
  @sep = @str.split(' ')
  @sep_map = @sep.map{|i| {}}
end

def identify_all_by_pattern
  @sep_map.each_with_index do |part, i|
    @sep_map[i][:from_pattern] = pattern_options(part)
  end
end

def pattern_options(part)
  opts = []
  opts << :street_number if potential_street_number(part)
  opts << :street_name if potential_street_name(part)
  opts << :street_label if potential_street_label(part)
  opts << :street_direction if potential_street_direction(part)
  opts << :unit if potential_unit(part)
  opts << :city if potential_city(part)
  opts << :state if potential_state(part)
  opts << :postal_code if potential_postal_code(part)
  opts << :country if potential_country(part)
  opts
end

def potential_street_number(part)
  return true if some_numbers(part)
  return true if %w[box po].include?(part[:down])
end

def potential_street_name(part)
  true
end

def potential_street_label(part)
  %w[avenue ave boulevard blvd circle cir court ct drive dr expressway expy highway hwy lane ln parkway pkwy place pl plaza plz road rd route rt square sq street st terrace tr trail trl way wy].include?(part[:down])
end

def potential_street_direction(part)
  %w[e n s w east north south west no so ne nw se sw northeast northwest southeast southwest].include?(part[:down])
end

def potential_unit(part)
  return true if part[:down].start_with?('#')
  return true if part[:down].start_with?('apt')
  return true if part[:down].start_with?('ste')
  return false
end

def potential_city(part)
  letters_only(part)
end

def potential_state(part)
  return true if NYAConstants::STATE_DESCRIPTORS.include?(part[:down])
  return true if letters_only(part) and part[:down].length < 5
  return false
end

def potential_postal_code(part)
  case part[:typified]
  when '|||||'
    true
  when '|||||-||||'
    true
  when '|||||||||'
    true
  when '=|= |=|'
    true
  when '=|='
    true
  else
    false
  end
end

def potential_country(part)
  letters_only(part)
end

def identify_all_by_location
  nParts = @sep.length
  @sep_map.each_with_index do |part, i|
    @sep_map[i][:from_location] = location_options(part, i, nParts)
  end
end

def location_options(part, i, nParts)
  case i
  when 0
    [:street_number, :street_name]
  when 1
    [:street_number, :street_name, :street_direction]
  when 2
    [:street_name, :street_label, :street_unit]
  when nParts - 3
    [:city, :state]
  when nParts - 2
    [:state, :postal_code]
  when nParts - 1
    [:postal_code, :country]
  else
    [:street_name, :street_label, :street_direction, :unit, :city, :state]
  end
end

def consolidate_identity_options
  @sep_map.each do |part|
    part[:in_both] = part[:from_location] & part[:from_pattern]
  end
end

def letters_only(part)
  !part[:typified].include?('|')
end

def some_numbers(part)
  part[:typified].include?('|')
end

def set_locale
  @nya.typify
  @locale = if @nya.typified.include?('=|= |=|')
    :ca 
  else
    :us
  end
end

end
