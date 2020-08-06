#load 'lib/addressor_utils.rb'
#load 'lib/extensions.rb'

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

    ## Remove special characters
    @str = @str.gsub('"', '')
    @str = @str.gsub("\u00A0", ' ')

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
    ## Remove extraneous information from the address
    @sep_comma.each_with_index do |sep, i|
      if ( (sep[0] == 'corner' or sep[1] == 'coner') and sep[1] == 'of') or (sep[0] == 'on' and sep[2] == 'corner')
        @bus[:extra_street] = sep.join(' ')
        @sep_comma.delete sep
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
    @sep.each_with_index do |word, i|
      if word == @sep[i+1]
        @sep.delete_at i
      end
    end

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
  return true if part[:text].has_digits?
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
  return true if not part[:text].numeric? and part[:text].length == 1 and not 'nsew'.include? part[:text]
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
  when '||||'
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
  when '=|=|=|'
    true
  else
    return true if part[:text].delete('o').numeric? and part[:text].length > 3
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
    sep[:confirmed] = []
  end
  confirm_country
  confirm_postal_code
  confirm_state_options
  confirm_street_number_options
  confirm_street_label_options
  confirm_direction_options
  confirm_unit_options
  confirm_street_name_options
  confirm_city_options
end

def confirm_country
  last_sep = @sep_map.last
  if @sep_map.last[:in_both].include? :country
    @sep_map.last[:confirmed] = [:country]
  end
end

def confirm_postal_code
  @sep_map.reverse.each do |sep|
    if sep[:in_both].include? :postal_code
      sep[:confirmed] = [:postal_code]
    end
  end
end

def confirm_unit_options
  @sep_map.each_with_index do |sep, i|
    if sep[:from_pattern].include? :unit and sep[:confirmed] == [] and not sep[:text].numeric?
      sep[:confirmed] = [:unit]
      if @sep_map[i+1][:text].has_digits?
        @sep_map[i+1][:confirmed] = [:unit]
      end
      break
    elsif sep[:in_both].include? :unit and sep[:confirmed] == [] #this may have broken some things
      sep[:confirmed] = [:unit]
    elsif sep[:typified][-1] == '=' and sep[:confirmed] == [:street_number] #if the unit is in the street number
      ind = -1
      # find where the number stops and the unit begins
      # sep[:text].split(//).each_with_index do |char, chari|
      sep[:text].split("").each_with_index do |char, chari|
        if not char.numeric? or char == '-'
          ind = chari
          break
        end
      end

      #update the street number
      if ind != -1
        sep[:orig] = sep[:text]
        unit = sep[:text][ind,999].delete '-'
        sep[:text] = sep[:text][0,ind]
        #append the unit
        @sep_map << {text: unit, confirmed: [:unit], in_both: [:unit], from_pattern: [:unit], from_location: [:unit], typified: "g"}
      end
    end
  end
end

def confirm_state_options
  found = false
  @sep_map.reverse.each do |sep|
    if sep[:in_both].include? :state and found
      sep[:in_both].delete(:state)
    elsif sep[:in_both].include? :state
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
  if (first_sep[:text].numeric? or first_sep[:typified] == '||||-||' or first_sep[:typified] == '|||-|||||' or first_sep[:typified] == '|||/|||||' or first_sep[:typified] == '=|||=|||||') and first_sep[:in_both].include? :street_number
    first_sep[:confirmed] = [:street_number]
  elsif first_sep[:typified] == '=|||' and @sep_map[1][:typified] == '=|||||' #canadian
    first_sep[:confirmed] = [:street_number]
    first_sep[:orig] = first_sep[:text]
    first_sep[:text] = first_sep[:text] + @sep_map[1][:text]
    @bus[:street_num] = @sep_map[1][:text]
    @sep_map.delete_at 1
  elsif first_sep[:typified][-1] == '=' and first_sep[:text].reverse[1,999].numeric?
    first_sep[:confirmed] = [:street_number]
  end
end


def confirm_street_name_options
  #we know: state, num, unit, label, dir
  #find what we know
  num_ind = -1
  lab_ind = -1
  dir_ind = -1
  @sep_map.each_with_index do |sep, i|
    if num_ind == -1 and sep[:confirmed] == [:street_number]
      num_ind = i
    elsif lab_ind == -1 and sep[:confirmed] == [:street_label]
      lab_ind = i
    elsif dir_ind == -1 and sep[:confirmed] == [:street_direction]
      dir_ind = i
    elsif num_ind != -1 and lab_ind != -1 and dir_ind != -1
      break
    end
  end
  # Find start and stop index
  name_start_index = -1
  name_stop_index = -1
  if num_ind != -1 and lab_ind != -1 and dir_ind != -1 and dir_ind < lab_ind and num_ind < dir_ind #direction comes before the label
    name_start_index = dir_ind + 1
    name_stop_index = lab_ind - 1
  elsif num_ind != -1 and lab_ind != -1
    name_start_index = num_ind + 1
    if @sep_map[lab_ind+1][:text].numeric?
      name_stop_index = lab_ind + 1
    else
      name_stop_index = lab_ind - 1
    end
  elsif num_ind != -1 and dir_ind != -1 and num_ind+1 != dir_ind
    name_start_index = num_ind + 1
    name_stop_index = dir_ind - 1
  elsif num_ind != -1 #find the sep comma
    name_start_index = num_ind + 1
    comma_index = -1
    @sep_comma.each_with_index do |com, comi|
      if com.include? @sep_map[name_start_index][:text]
        comma_index = comi
        break
      end
    end
    last_word = @sep_comma[comma_index].last
    @sep_map.each_with_index do |sep, i|
      if sep[:text] == last_word
        name_stop_index = i
      end
    end
  end

  ##If start wasnt found
  if name_start_index == -1
    @sep_map.each_with_index do |sep, i| #find the first word without numbers
      if not sep[:text].has_digits?
        name_start_index = i
        break
      end
    end
  end

  #make sure start and stop are in the same sep_comma
  if name_stop_index != -1
    first_word = @sep_map[name_start_index][:text]
    last_word = @sep_map[name_stop_index][:text]
    @sep_comma.each do |comma|
      if comma.include? first_word and not comma.include? last_word
        name_stop_index = -1
      end
    end
  end

  #if stop wasn't found
  if name_stop_index == -1
    #find the last word in the first sep_comma
    last_word = @sep_comma[0].last
    @sep_map.each_with_index do |sep, i|
      if sep[:text] == last_word
        name_stop_index = i
      end
    end
  end

  ## Select the street name
  if name_start_index != -1 and name_stop_index != -1
    (name_start_index..name_stop_index).each do |index|
      if @sep_map[index][:confirmed] == []
        @sep_map[index][:confirmed] = [:street_name]
      end
    end
  else

    puts "THIS WAS CALLED: confirm_street_name_options name_stop_index = #{name_stop_index} || name_start_index = #{name_start_index} from: #{@nya.orig}"
  end

end #confirm_street_name_options



def confirm_direction_options
  #we know: state, unit, number, street
  directions_found = []
  street_number = ""
  #Find all directions
  @sep_map.each_with_index do |sep, i|
    if sep[:confirmed] == [:street_number]
      street_number = sep[:text]
    elsif sep[:in_both].include? :street_direction and @sep_map[i+1][:confirmed] == [:street_label]
      sep[:in_both].delete :street_direction
    elsif sep[:from_pattern].include? :street_direction
      ## Find what sep_comma the number is in
      num_comma = -1
      @sep_comma.each_with_index do |comma, comi|
        if comma.include? street_number
          num_comma = comi
          break
        end
      end

      @sep_comma.each_with_index do |comma, comi|
        if comma.include? street_number and comma.include? sep[:text]
          directions_found << sep
        elsif comma.include? sep[:text] and comi == num_comma+1 and comma.length == 1
          directions_found << sep
        end
      end
    end
  end #@sep_map.each_with_index

  #chose between directions
  if directions_found.length > 1
    short_dir_found = false
    #short dir is typically the correct one (Ex: N > North)
    directions_found.each do |direction|
      if direction[:text].length < 3
        short_dir_found = true
      end
    end #end find short dir

    #remove non-short dirs
    if short_dir_found
      directions_found.each do |direction|
        if direction[:text].length > 2
          directions_found.delete(direction)
        end
      end
    end #if short_dir_found

    #Typically the latter dir is the correct one
    directions_found.last[:confirmed] = [:street_direction]

  elsif directions_found.length == 1
    directions_found[0][:confirmed] = [:street_direction]
  end #directions_found.length
end #End direction options

def confirm_street_label_options
  #we know: number and state
  found_label = false
  @sep_map.reverse.each_with_index do |sep, i|
    if not found_label and sep[:from_pattern].include? :street_label and sep[:confirmed] == []

      ## Find the street number
      snum = ""
      @sep_map.each do |sep2|
        if sep2[:confirmed] == [:street_number]
          if sep2[:orig].nil?
            snum = sep2[:text]
          else
            snum = sep2[:orig]
          end
        end
      end
      #Make sure it's in the same sep_comma as number
      if snum.length > 0
        @sep_comma.each do |comma|
          if comma.include? snum and comma.include? sep[:text]
            sep[:confirmed] = [:street_label]
            found_label = true
            if sep[:text] == 'way' #check for compound label (ex: express way, high way, park way)
              compound = @sep_map[i-1][:text] + sep[:text]
              if NYAConstants::LABEL_DESCRIPTORS.include? compound
                @sep_map[i-1][:confirmed] = [:street_label]
                @sep_map[i-1][:orig] = @sep_map[i-1][:text]
                @sep_map[i-1][:text] = compound
                sep[:confirmed] = []
              end
            end
          end
        end
      end
    end
  end
end #end confirm_street_label_options


def confirm_city_options
  #we know: pretty much everything
  low_end = []
  high_end = []
  @sep_map.each_with_index do |sep, i|
    if sep[:confirmed] == [:street_name] or sep[:confirmed] == [:street_label] or sep[:confirmed] == [:street_direction]
      low_end << i
    elsif sep[:confirmed] == [:state] or sep[:confirmed] == [:postal_code]
      high_end << i
    end
  end

  if not low_end.max.nil? and not high_end.min.nil?
    city_start_index = low_end.max + 1
    city_stop_index = high_end.min - 1

    #find city sep_comma
    comma_index = -1
    @sep_comma.each_with_index do |comma, comi|
      if comma.include? @sep_map[city_stop_index][:text]
        comma_index = comi
        break
      end
    end

    (city_start_index..city_stop_index).each do |index|
      if @sep_map[index][:confirmed] == [] and not @sep_map[index][:text].has_digits?
        if comma_index == -1
          @sep_map[index][:confirmed] = [:city]
        elsif @sep_comma[comma_index].include? @sep_map[index][:text] #make sure they're in the same sep comma
          @sep_map[index][:confirmed] = [:city]
        end
      end
    end
  end

end #confirm city options


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
    if sep[:confirmed].include? :street_number and (sep[:text].include? '-' or sep[:text].include? '/')
      dash = sep[:text].index '-'
      if dash.nil?
        dash = sep[:text].index '/'
      end
      #seperate the dashes
      if sep[:text][0,4].numeric?
        sep[:orig] = sep[:text]
        @bus[:street_num] = sep[:text][dash,999]
        sep[:text] = sep[:text][0,dash]
      elsif sep[:text].reverse()[0,4].numeric?
        sep[:orig] = sep[:text]
        @bus[:street_num] = sep[:text][0,dash]
        sep[:text] = sep[:text][dash+1,999]
      end
    elsif sep[:confirmed].include? :street_name and NYAConstants::NUMBER_STREET.keys.include? sep[:text]
      sep[:text] = NYAConstants::NUMBER_STREET[sep[:text]]
    elsif sep[:confirmed].include? :street_direction and NYAConstants::STREET_DIRECTIONS.keys.include? sep[:text]
      sep[:text] = NYAConstants::STREET_DIRECTIONS[sep[:text]]
    elsif sep[:confirmed].include? :street_label and NYAConstants::STREET_LABELS.keys.include? sep[:text]
      sep[:text] = NYAConstants::STREET_LABELS[sep[:text]]
    elsif sep[:confirmed].include? :unit
      sep[:text] = sep[:text].delete '#'
      sep[:text] = sep[:text].tr('a-z', '') if sep[:text].letter_count > 1
    elsif sep[:confirmed].include? :state and NYAConstants::STATE_KEYS.include? sep[:text]
      sep[:orig] = sep[:text]
      sep[:text] = NYAConstants::US_STATES[sep[:text].capitalize()] if NYAConstants::US_STATES[sep[:text].capitalize()]
      sep[:text] = NYAConstants::CA_PROVINCES[sep[:text].capitalize()] if NYAConstants::CA_PROVINCES[sep[:text].capitalize()]
    elsif sep[:confirmed].include? :postal_code and sep[:text].include? 'o'
      sep[:text] = sep[:text].gsub('o', '0')
    end
  end
end #def standardize_aliases

def check_requirements
  #Street number but no name?
  if @parts[:street_name].nil? and not @parts[:street_number].nil? and not @parts[:street_number].numeric?
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

  #Unit but no name
  if @parts[:street_name].nil? and not @parts[:unit].nil? and not @parts[:unit].to_s.has_digits?
    @parts[:street_name] = @parts[:unit]
    @parts[:unit] = nil
  end

  ## No street direction? check the bus
  if @parts[:street_direction].nil? and not @bus[:nil].nil?
    possible_dir = ""
    @bus[:nil].each do |unknown|
      if NYAConstants::DIRECTION_DESCRIPTORS.include? unknown
        possible_dir = unknown
      end
    end

    #Make sure it comes before the state
    dir_ind = @nya.orig.downcase.index possible_dir
    state_ind = nil
    @sep_map.each do |sep|
      if sep[:confirmed] == [:state]
        if sep[:orig].nil?
          state_ind = @nya.orig.downcase.index sep[:text]
        else
          state_ind = @nya.orig.downcase.index sep[:orig]
        end
      end
    end
    if not state_ind.nil?
      if dir_ind < state_ind
        @parts[:street_direction] = possible_dir
      end
    end
  end #if @parts[:street_direction].nil?

  ## No unit? check the bus
  if @parts[:unit].nil? and not @bus[:street_num].nil?
    @parts[:unit] = @bus[:street_num]
  end

  ## Remove duplicate city
  if not @parts[:city].nil?
    @parts[:city] = @parts[:city].split(' ').uniq.join(' ')
  end

  #Make sure there are enough parts
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
