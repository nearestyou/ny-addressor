load 'lib/addressor_utils.rb'
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
    confirm_identity_options
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
    if @str.include? '-'
      dash = @str.index('-')
      if not @str[dash-1].numeric? or not @str[dash+1].numeric?
        @str = @str.gsub('-', '')
      end
    end
    if @str.include? '&'
      amp = @str.index('&')
      if amp < 6 and (@str[amp-1].numeric? or @str[amp-2].numeric?) and (@str[amp+1].numeric? or @str[amp+2].numeric?)
        first_number = amp + 1
        if @str[first_number] == ' '
          first_number += 1
        end
        @str = @str[first_number, 9000]
      end
    end

    ## Lowercase
    @str = @str.downcase

    ## Remove duplicates
    # @str = @str.split(' ').reverse.uniq.reverse.join(' ')
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
      if sep.map.include? 'corner' or sep.map.include? 'coner' or sep.map.include? 'route' or sep.map.include? 'plaza' or sep.map.include? 'shopping' and @sep_comma.length > 3
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
  return false if NYAConstants::UNIT_DESCRIPTORS.include? part[:text]
  return true if some_numbers(part)
  return true if %w[box po].include?(part[:text])
end

def potential_street_name(part)
  return false if NYAConstants::UNIT_DESCRIPTORS.include? part[:text]
  return true
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

def confirm_identity_options
  @sep_map.each do |sep|
    sep[:confirmed] = sep[:in_both]
  end

  confirm_state_options
  confirm_street_number_options
  confirm_unit_options
  confirm_street_name_options
  confirm_direction_options
  confirm_street_label_options
  confirm_city_options
end

def confirm_unit_options
  @sep_map.each_with_index do |sep, i|
    if sep[:confirmed] == [:unit]
      if not sep[:text].has_digits? and @sep_map[i+1][:text].has_digits?
        @sep_map[i+1][:confirmed] = [:unit]
      end
      break
    end
  end
end

def confirm_state_options
  found = false
  @sep_map.reverse.each do |sep|
    if sep[:confirmed].include? :state and found
      sep[:confirmed].delete(:state)
    elsif sep[:confirmed].include? :state
      found = true
      sep[:confirmed] = [:state]
    end
  end
  #Check for compound state
  if not found
    @sep_map.reverse.each_with_index do |sep, i|
      if i+1 < @sep_map.length
        if NYAConstants::STATE_DESCRIPTORS.include?("#{sep_map.reverse[i+1][:text]} #{sep[:text]}")
          sep_map.reverse[i+1][:confirmed] = [:state]
          sep_map.reverse[i][:confirmed] = [:state]
        end
      end
    end
  end
end

def confirm_street_number_options
  first_sep = @sep_map[0]
  if first_sep[:text].length == 4 and first_sep[:text].numeric?
    first_sep[:confirmed] = [:street_number]
  end
end

def confirm_street_name_options
  #Find start and stop points
  name_start_index = -1
  name_stop_index = -1
  @sep_map.each_with_index do |sep, i|
    if @sep_map.length > i+1
      if name_start_index != -1 and name_stop_index == -1 and (sep[:confirmed].include? :street_label or sep[:confirmed].include? :street_direction or sep[:confirmed].include? :city)
        name_stop_index = i-1
        break
      elsif (sep[:confirmed].include? :street_number or sep[:confirmed].include? :street_direction) and name_start_index == -1 and not @sep_map[i+1][:confirmed].include? :street_direction
        name_start_index = i+1
      elsif i == 0 and not sep[:confirmed].include? :street_number and not sep[:confirmed].include? :street_direction and not sep[:confirmed].include? :unit
        name_start_index = 0
      end
    end
  end
  #eliminate options
  comma_index = -1
  @sep_map.each_with_index do |sep, i|
    if i >= name_start_index and i <= name_stop_index and name_start_index != -1 and name_stop_index != -1
      sep[:confirmed] = [:street_name]
    elsif sep[:confirmed].include? :street_name and name_start_index != -1 and name_stop_index != -1
      sep[:confirmed].delete :street_name
    elsif name_stop_index == -1 and comma_index == -1 and sep[:confirmed].include? :street_name
      @sep_comma.each_with_index do |comma, ind|
        if comma.include? sep[:text]
          comma_index = ind
        end
      end
    elsif name_stop_index == -1 and comma_index != -1 and sep[:confirmed].include? :street_name and not @sep_comma[comma_index].include? sep[:text]
      sep[:confirmed].delete(:street_name)
    end
  end
end

def confirm_direction_options
  @sep_map.each_with_index do |sep, i|
    if sep[:confirmed].include? :street_direction and @sep_map[i+1][:confirmed].include? :city and not sep[:confirmed].include? :city
      sep[:confirmed] = [:street_direction]
      break
    end
  end
end

def confirm_street_label_options
  found = false
  @sep_map.each_with_index do |sep, i|
    if found and sep[:confirmed].include? :street_label
      sep[:confirmed].delete :street_label
    elsif sep[:confirmed].include? :street_label and @sep_map[i-1][:confirmed].include? :street_name
      sep[:confirmed] = [:street_label]
      found = true
    end
  end
end

def confirm_city_options
  found_state = false
  @sep_map.reverse.each_with_index do |sep, i|
    if sep[:confirmed] == [:street_label] or sep[:confirmed] == [:street_direction]
      break
    elsif not sep[:confirmed].include? :city and found_state and not sep[:confirmed].include? :state and not sep[:text].numeric?
      sep[:confirmed].push(:city)
    elsif sep[:confirmed].include? :city and sep[:confirmed] != [:city] and @sep_comma.length > i
      if @sep_comma[i].include? sep[:text]
        sep[:confirmed] = [:city]
      else
        sep[:confirmed].delete :city
      end
    elsif sep[:confirmed].include? :state
      found_state = true
    end
  end
  ## If they are not in the same @sep_comma, they are not both cities
  city_comma = -1
  @sep_map.reverse.each do |sep|
    if sep[:confirmed].include? :city and city_comma == -1
      @sep_comma.each_with_index do |sepc, i|
        if sepc.include? sep[:text]
          city_comma = i
        end
      end
    elsif sep[:confirmed].include? :city and city_comma != -1
      if not @sep_comma[city_comma].include? sep[:text]
        sep[:confirmed].delete(:city)
      end
    end
  end
end # end confirm_city

def check_po
  po_box = false
  @sep_map.each do |sep|
    if NYAConstants::POBOX_ALIAS.include? sep[:text]
      po_box = true
      break
    end
  end

  if po_box
    @sep_map[0][:confirmed] = [:street_name]
    @sep_map[1][:confirmed] = [:street_name]
    @sep_map[2][:confirmed] = [:street_number]
    if @sep_map[3][:text].numeric?
      @sep_map[3][:confirmed] = [:street_number]
    end
  end
end

def select_final_options
  @parts = {}
  @sep_map.each do |sep|
    label = sep[:confirmed].first
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
    if sep[:confirmed].include? :street_number and sep[:text].include? '-' or sep[:text].include? '/'
      sep[:text] = sep[:text].reverse()[0,5].reverse()
    elsif sep[:confirmed].include? :street_name and NYAConstants::NUMBER_STREET.keys.include? sep[:text]
      sep[:text] = NYAConstants::NUMBER_STREET[sep[:text]]
    elsif sep[:confirmed].include? :street_direction and NYAConstants::STREET_DIRECTIONS.keys.include? sep[:text]
      sep[:text] = NYAConstants::STREET_DIRECTIONS[sep[:text]]
    elsif sep[:confirmed].include? :street_label and NYAConstants::STREET_LABELS.keys.include? sep[:text]
      sep[:text] = NYAConstants::STREET_LABELS[sep[:text]]
    elsif sep[:confirmed].include? :state and NYAConstants::STATE_KEYS.include? sep[:text]
      sep[:text] = NYAConstants::US_STATES[sep[:text].capitalize()] if NYAConstants::US_STATES[sep[:text].capitalize()]
      sep[:text] = NYAConstants::CA_PROVINCES[sep[:text].capitalize()] if NYAConstants::CA_PROVINCES[sep[:text].capitalize()]
    end
  end
end

def check_requirements
  #Street number but no name?
  if @parts[:street_name].nil? and not @parts[:street_number].nil?
    @parts[:street_name] = @parts[:street_number]
    @parts.delete(:street_number)
  end

  #Street name but no number?
  if @parts[:street_number].nil? and not @parts[:street_name].nil? and @parts[:street_name].include? ' '
    parts = @parts[:street_name].split(' ')
    @parts[:street_name] = ""
    @parts[:street_number] = ""
    found_num = false
    parts.each do |part|
      if part.numeric? and not found_num
        @parts[:street_number] = part
        found_num = true
      else
        @parts[:street_name] << part + ' '
      end
    end
    @parts[:street_name] = @parts[:street_name].chop()
  end

  #Number/unit but no name?
  if @parts[:street_name].nil? and (not @parts[:unit].nil? or not @parts[:street_number].nil?)
    if not @bus[:extra_street].nil?
      @parts[:street_name] = ""
      @sep_comma.each do |comma|
        if @parts[:street_name] != ""
          @parts[:street_name] = @parts[:street_name].chop
          break
        else
          comma.each do |word|
            if @bus[:extra_street].include? word
              debugger #this is here because it's never been triggered before
              @parts[:street_name] += word + ' '
              @bus[:extra_street].delete(word)
            end
          end
        end
      end
    elsif not @bus[:nil].nil?
      @parts[:street_name] = ""
      @sep_comma.each do |comma|
        if @parts[:street_name] != ""
          @parts[:street_name] = @parts[:street_name].chop
          break
        else
          comma.each do |word|
            if @bus[:nil].include? word
              @parts[:street_name] += word + ' '
              @bus[:nil].delete(word)
            end
          end
        end
      end
    end
  end

  if @parts.size() < 4
    @parts = nil
  end
end #End check requirements

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
