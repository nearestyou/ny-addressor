#load 'lib/addressor_utils.rb'
#load 'lib/extensions.rb'

class NYIdentifier
attr_accessor :str, :sep, :sep_map, :locale, :bus
  def initialize(nya = nil

  def identify
    confirm_identity_options
    standardize_aliases
    select_final_options
    check_requirements
  end

# def potential_postal_code(part)
#   case part[:typified]
#   when '|||||'
#     true
#   when '||||'
#     true
#   when '|||||-||||'
#     true
#   when '|||||||||'
#     true
#   when '=|= |=|'
#     true
#   when '=|='
#     true
#   when '|=|'
#     true
#   when '=|=|=|'
#     true
#   when '==||' #burmuda
#     true
#   else
#     return true if part[:text].delete('o').numeric? and part[:text].length > 3 #This can be better !!
#     false
#   end
# end


def confirm_identity_options
  @sep_map.each do |sep|
    sep[:confirmed] = []
  end
  confirm_country
  confirm_postal_code
  confirm_state_options
  confirm_unit_options
  confirm_street_number_options
  check_street_number_unit
  confirm_street_label_options
  confirm_direction_options
  confirm_street_name_options
  confirm_city_options
end



# def confirm_street_number_options
#   if (first_sep[:text].numeric? or first_sep[:typified] == '||||-||' or first_sep[:typified] == '|||-|||||' or first_sep[:typified] == '|||/|||||' or first_sep[:typified] == '=|||=|||||') and first_sep[:in_both].include? :street_number
#     first_sep[:confirmed] = [:street_number]
#   elsif first_sep[:typified] == '=|||' and @sep_map[1][:typified] == '=|||||' #canadian
#     first_sep[:confirmed] = [:street_number]
#     first_sep[:orig] = first_sep[:text]
#     first_sep[:text] = first_sep[:text] + @sep_map[1][:text]
#     @bus[:street_num] = @sep_map[1][:text]
#     @sep_map.delete_at 1
#   elsif first_sep[:typified][-1] == '=' and first_sep[:text].reverse[1,999].numeric?
#     first_sep[:confirmed] = [:street_number]
#   end
# end #confirm_street_number_options




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

  #STATE ALIASES
    # elsif sep[:confirmed].include? :state and NYAConstants::STATE_KEYS.include? sep[:text]
    #   sep[:orig] = sep[:text]
    #   sep[:text] = NYAConstants::US_STATES[sep[:text].capitalize()] if NYAConstants::US_STATES[sep[:text].capitalize()]
    #   sep[:text] = NYAConstants::CA_PROVINCES[sep[:text].capitalize()] if NYAConstants::CA_PROVINCES[sep[:text].capitalize()]

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

  ## Country but no city?
  if not @parts[:country].nil? and @parts[:city].nil?
    @parts[:city] = @parts[:country]
    @parts[:country] = ""
    #Check the sep_comma (because it could be a compound city)
    if not @bus[:nil].nil?
      @sep_comma.reverse.each_with_index do |comma, i|
        if comma.include? @parts[:city]
          @parts[:city] = ""
          comma.each do |word|
            @parts[:city] += word + ' '
          end
          @parts[:city].chop
          break
          debugger
        end
      end
    end
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
