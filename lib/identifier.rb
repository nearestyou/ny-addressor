load 'lib/addressor_utils.rb'
load 'lib/constants.rb'
load 'lib/extensions.rb'

class NYIdentifier
attr_accessor :str, :sep, :sep_map, :locale, :bus
  def initialize(nya = nil)
    @nya = nya
    @str = nya.orig.to_s
    @bus = {}
    self
  end

  def identifications
    identify
    { sep: @sep, sep_map: @sep_map, sep_comma: @sep_comma, locale: @locale, bus: @bus, parts: @parts }
  end

  def identify
    pre_extra
    create_sep_comma
    extra_sep_comma
    seperate
    post_extra
    # update_sep_comma #idk how to do this :|
    create_sep_map
    identify_all_by_pattern
    identify_all_by_location
    consolidate_identity_options
    strip_identity_options
    # check_po #not working
    standardize_aliases
    select_final_options
    check_requirements
  end

  def pre_extra
    ## Remove parentheses
    while @str.include?('(') and @str.include?(')')
      open = @str.index('(')
      close = @str.index(')')
      @bus[:parentheses] ||= []
      @bus[:parentheses] << @str[open+1..close-1]
      @str = @str[0..open-1] + @str[close+1..-1]
    end

    ## Remove punctuation
    @str = @str.gsub('.', '')

    ## Lowercase
    @str = @str.downcase
  end

  def create_sep_comma
    @sep_comma = []
    @str.split(',').each do |comma|
      words = comma.split(' ')
      @sep_comma.push comma.split(' ')
    end
  end

  def extra_sep_comma
    ## removing extra street data
    @sep_comma.reverse.each do |sep|
      if sep.map.include? 'corner' or sep.map.include? 'coner' or sep.map.include? 'route' or sep.map.include? 'plaza' and @sep_comma.length > 3
        @sep_comma.delete(sep)
        @bus[:extra_street] = sep.join(' ')
      end
    end
  end

  def seperate
    @sep = []
    @sep_comma.each do |comma|
      comma.each do |word|
        @sep.push word
      end
    end
  end

  def post_extra
    ## Remove duplicates
    @sep = @sep.uniq

    ## Remove different ways to say 'usa'
    og = @nya.orig.downcase
    alias_index = []
    start_index = []
    NYAConstants::US_ALIAS.each do |name|
      if og.include? name
        start = og.index(name)
        if not start_index.include? start
          start_index.push(start)
          alias_index.push([start, name.length])
        end
      end
    end
    while alias_index.length > 1
      abrev = og[alias_index[0][0], alias_index[0][1]]
      abrev = abrev.split(' ')
      abrev.each do |word|
        @sep.delete(word)
      end
      alias_index.delete_at(0)
    end
  end ##end post_extra

  def create_sep_map
    @sep_map = @sep.map{|part| {text:part, typified:AddressorUtils.typify(part)}}
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
  return true if %w[box po].include?(part[:text])
end

def potential_street_name(part)
  true
end

def potential_street_label(part)
  NYAConstants::LABEL_DESCRIPTORS.include? part[:text]
end

def potential_street_direction(part)
  NYAConstants::DIRECTION_DESCRIPTORS.include? part[:text]
end

def potential_unit(part)
  return true if NYAConstants::UNIT_DESCRIPTORS.include? part[:text]
  return true if part[:text].numeric? and part[:text].length < 4
  return true if part[:text].include? '#'
  return false
end

def potential_city(part)
  letters_only(part)
end

def potential_state(part)
  return true if NYAConstants::STATE_DESCRIPTORS.include?(part[:text])
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
  when '|=|'
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
    [:street_number, :street_name, :unit]
  when 1
    [:street_number, :street_name, :street_direction, :street_label]
  when 2
    [:street_name, :street_label, :street_unit, :street_direction]
  when nParts - 3
    [:city, :state, :postal_code]
  when nParts - 2
    [:state, :postal_code]
  when nParts - 1
    [:state, :postal_code, :country]
  else
    [:street_name, :street_label, :street_direction, :unit, :city, :state]
  end
end

def consolidate_identity_options
  @sep_map.each do |part|
    part[:in_both] = part[:from_location] & part[:from_pattern]
  end
end

def strip_identity_options
  @sep_map.each do |sep|
    sep[:stripped] = sep[:in_both]
  end
  # debugger
  strip_state_options
  strip_street_number_options
  strip_street_name_options
  strip_unit_options
  strip_direction_options
  strip_street_label_options
  strip_city_options
end

def strip_unit_options
  ## Finding units
  unit_found = []
  @sep_map.each_with_index do |sep, i|
    if sep[:stripped] == [:unit] and unit_found.length == 0
      unit_found.push sep[:text]
      if not sep[:text].has_digits? and @sep_map[i+1][:text].has_digits?
        @sep_map[i+1][:stripped] = [:unit]
        unit_found.push @sep_map[i+1][:text]
      end
    end
  end
end ##End strip_unit_options

def strip_state_options
  found = false
  @sep_map.reverse.each do |sep|
    if sep[:stripped].include? :state and found
      sep[:stripped].delete(:state)
    elsif sep[:stripped].include? :state
      found = true
      sep[:stripped] = [:state]
    end
  end
  #Check for compound state
  if not found
    @sep_map.reverse.each_with_index do |sep, i|
      if i+1 < @sep_map.length
        if NYAConstants::STATE_DESCRIPTORS.include?("#{sep_map.reverse[i+1][:text]} #{sep[:text]}")
          sep_map.reverse[i+1][:stripped] = [:state]
          sep_map.reverse[i][:stripped] = [:state]
        end
      end
    end
  end
end

def strip_street_number_options
  first_sep = @sep_map[0]
  if first_sep[:text].length == 4 and first_sep[:text].numeric?
    first_sep[:stripped] = [:street_number]
  end
end

def strip_street_name_options
  #Find start and stop points
  name_start_index = -1
  name_stop_index = 0
  @sep_map.each_with_index do |sep, i|
    if @sep_map.length > i+1
      if name_start_index != -1 and sep[:text] == 'plaza'
        name_stop_index = i-1
        sep[:stripped] = [:street_label]
        break
      elsif name_start_index != -1 and name_stop_index == 0 and (sep[:stripped].include? :street_label or sep[:stripped].include? :street_direction or sep[:stripped].include? :city)
        name_stop_index = i-1
        break
      elsif (sep[:stripped].include? :street_number or sep[:stripped].include? :street_direction) and name_start_index == -1 and not @sep_map[i+1][:stripped].include? :street_direction
        name_start_index = i+1
      elsif i == 0 and not sep[:stripped].include? :street_number and not sep[:stripped].include? :street_direction and not sep[:stripped].include? :unit
        name_start_index = 0
      end
    end
  end
  #eliminate options
  @sep_map.each_with_index do |sep, i|
    if i >= name_start_index and i <= name_stop_index
      sep[:stripped] = [:street_name]
    elsif sep[:stripped].include? :street_name
      sep[:stripped].delete :street_name
    end
  end
end

def strip_direction_options
  @sep_map.each_with_index do |sep, i|
    if sep[:stripped].include? :street_direction and @sep_map[i+1][:stripped].include? :city and not sep[:stripped].include? :city
      sep[:stripped] = [:street_direction]
      break
    end
  end
end

def strip_street_label_options
  found = false
  @sep_map.each_with_index do |sep, i|
    if found and sep[:stripped].include? :street_label
      sep[:stripped].delete :street_label
    elsif sep[:stripped].include? :street_label and @sep_map[i-1][:stripped].include? :street_name
      sep[:stripped] = [:street_label]
      found = true
    end
  end
end

def strip_city_options
  found_state = false
  @sep_map.reverse.each_with_index do |sep, i|
    if sep[:stripped] == [:street_label] or sep[:stripped] == [:street_direction]
      break
    elsif not sep[:stripped].include? :city and found_state and not sep[:stripped].include? :state and not sep[:text].numeric?
      sep[:stripped].push(:city)
    elsif sep[:stripped].include? :city and sep[:stripped] != [:city] and @sep_comma.length > i
      if @sep_comma[i].include? sep[:text]
        sep[:stripped] = [:city]
      else
        sep[:stripped].delete :city
      end
    elsif sep[:stripped].include? :state
      found_state = true
    end
  end
  ## If they are not in the same @sep_comma, they are not both cities
  city_comma = -1
  @sep_map.reverse.each do |sep|
    if sep[:stripped].include? :city and city_comma == -1
      @sep_comma.each_with_index do |sepc, i|
        if sepc.include? sep[:text]
          city_comma = i
        end
      end
    elsif sep[:stripped].include? :city and city_comma != -1
      if not @sep_comma[city_comma].include? sep[:text]
        sep[:stripped].delete(:city)
      end
    end
  end
end # end strip_city

def check_po
  po_box = false
  @sep_map.each do |sep|
    if NYAConstants::POBOX_ALIAS.include? sep[:text]
      po_box = true
      break
    end
  end

  if po_box
    @sep_map[0][:stripped] = [:street_name]
    @sep_map[1][:stripped] = [:street_name]
    @sep_map[2][:stripped] = [:street_number]
    if @sep_map[3][:text].numeric?
      @sep_map[3][:stripped] = [:street_number]
    end
  end
end

def select_final_options
  @parts = {}
  @sep_map.each do |sep|
    label = sep[:stripped].first
    part = sep[:text]
    if @parts[label].nil? and not label.nil?
      @parts[label] = part
    elsif label.nil?
      (@bus[:nil] ||= []) << part #creates :nil if does not exist
    else
      if label == :street_direction
        @parts[label] = "#{@parts[label]}#{part}"
      else
        @parts[label] = "#{@parts[label]} #{part}"
      end
    end
  end
  @parts[:orig] = @nya.orig
  @parts[:bus] = @bus
end

def standardize_aliases
  @sep_map.each do |sep|
    if sep[:stripped].include? :street_number and sep[:text].include? '-' or sep[:text].include? '/'
      sep[:text] = sep[:text].reverse()[0,5].reverse()
    elsif sep[:stripped].include? :street_name and NYAConstants::NUMBER_STREET.keys.include? sep[:text]
      sep[:text] = NYAConstants::NUMBER_STREET[sep[:text]]
    elsif sep[:stripped].include? :street_direction and NYAConstants::STREET_DIRECTIONS.keys.include? sep[:text]
      sep[:text] = NYAConstants::STREET_DIRECTIONS[sep[:text]]
    elsif sep[:stripped].include? :street_label and NYAConstants::STREET_LABELS.keys.include? sep[:text]
      sep[:text] = NYAConstants::STREET_LABELS[sep[:text]]
    elsif sep[:stripped].include? :state and NYAConstants::STATE_KEYS.include? sep[:text]
      sep[:text] = NYAConstants::US_STATES[sep[:text].capitalize()] if NYAConstants::US_STATES[sep[:text].capitalize()]
      sep[:text] = NYAConstants::CA_PROVINCES[sep[:text].capitalize()] if NYAConstants::CA_PROVINCES[sep[:text].capitalize()]
    end
  end
end

def check_requirements
  if @parts[:street_name].nil? and not @parts[:street_number].nil?
    @parts[:street_name] = @parts[:street_number]
    @parts.delete(:street_number)
  end

  if @parts.size() < 4
    @parts = nil
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
