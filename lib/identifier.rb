class NYIdentifier
attr_accessor :str, :sep, :sep_map, :bus, :parts
  def initialize(str = nil)
    @orig = str
    @str = str.downcase
    @bus = {}
    identify
  end

  def identify
    pre_extra
    create_sep_comma
    extra_sep_comma
    seperate
    post_extra
    #update_sep_comma #this may not be nescessary
    create_sep_map
    identify_all_by_location
    identify_all_by_pattern
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
  end #pre_extra

  def create_sep_comma
    @sep_comma = []
    @str.split(',').each do |comma|
      words = comma.split(' ')
      @sep_comma.push words if words != []
    end
  end #create_sep_comma

  def extra_sep_comma
    ## Remove extraneous information from the address
    @sep_comma.each_with_index do |sep, i|
      if ( (sep[0] == 'corner' or sep[1] == 'coner') and sep[1] == 'of') or (sep[0] == 'on' and sep[2] == 'corner')
        @bus[:extra_street] = sep.join(' ')
        @sep_comma.delete sep
      end
    end
  end #extra_sep_comma

  def seperate
    @sep = []
    @sep_comma.each do |comma|
      comma.each do |word|
        @sep.push word
      end
    end
  end #seperate

  def post_extra
    ## Remove duplicates
    @sep.each_with_index do |word, i|
      if word == @sep[i+1]
        @sep.delete_at i
      end
      if word == '-'
        @sep.delete_at i
      end
    end
    ## Used to remove usa vs us in here
  end #post_extra

  def create_sep_map
    @sep_map = @sep.map{|part| {text:part, orig:part, typified:AddressorUtils.typify(part)}}
  end

  ###Location Options###
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
      [:street_number, :street_name, :street_label, :street_unit, :street_direction]
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
  ######Location Options######

  ###Identify by pattern###
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
    opts
  end

  def potential_street_number(part)
    return false if NYAConstants::UNIT_DESCRIPTORS.include? part[:text]
    return true if part[:text].has_digits?
    return true if %w[box po].include?(part[:text])
  end

    def potential_street_name(part)
      not NYAConstants::UNIT_DESCRIPTORS.include? part[:text]
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
      return true if part[:typified] == '=|' or part[:typified] == '|='
      return false
    end

    def potential_city(part)
      not part[:text].has_digits?
    end

  ######Identify by pattern######

  def consolidate_identity_options
    @sep_map.each do |part|
      part[:in_both] = part[:from_location] & part[:from_pattern]
      part[:confirmed] = nil
    end
  end

  ### Confirm Identity ###
  def confirm_identity_options
    confirm_country
    confirm_postal_code
    confirm_state
    confirm_unit
    confirm_street_number
    check_street_number_unit
    confirm_label
    confirm_direction
    confirm_street_name
    confirm_city
  end

  def confirm_country
    @sep_map.last[:confirmed] = :country if @sep_map.last[:from_pattern].include? :country
  end

  def confirm_postal_code
    @sep_map.reverse.each do |sep|
      sep[:confirmed] = :postal_code if sep[:in_both].include? :postal_code
      break if not sep[:from_location].include? :postal_code
    end
  end

  def confirm_state
    @sep_map.reverse.each_with_index do |sep, i|
      if sep[:in_both].include? :state
        sep[:confirmed] = :state
        break
      end
    end
  end

  def confirm_unit
    @sep_map.each_with_index do |sep, i|
      if sep[:from_pattern].include? :unit and sep[:confirmed].nil? and not sep[:text].has_digits?
        sep[:confirmed] = :unit
        @sep_map[i+1][:confirmed] = :unit if @sep_map[i+1][:text].has_digits? #compound unit
        break
      elsif sep[:in_both].include? :unit and sep[:confirmed].nil?
        if i == 0 and not @sep_map[1][:text].numeric?
        else
          sep[:confirmed] = :unit
        end
      end
    end
  end #confirm_unit_options

  def confirm_street_number
    first_sep = unconfirmed_sep
    if first_sep[:in_both].include? :street_number
      first_sep[:confirmed] = :street_number
    end
  end

  ## Check if there is a unit with the street_number
  def check_street_number_unit
    @sep_map.each_with_index do |sep, i|
      if sep[:confirmed] == :street_number and sep[:typified][-1] == '=' #if there is a letter at the end of the number
        number = sep[:text][0..-2]
        unit = sep[:text][-1]

        #update street_number
        sep[:orig] = sep[:text]
        sep[:text] = number
        new_sep = {text: unit, confirmed: [:unit], in_both: [:unit], from_pattern: [:unit], from_location: [:unit], typified: '='}
        @sep_map << new_sep
        break
      end
    end
  end

  def confirm_label
    found = false
    snum = search_confirmed(:street_number)
    snum = snum[:orig] if snum
    @sep_map.reverse.each_with_index do |sep, i|
      if not found and sep[:from_pattern].include? :street_label and sep[:confirmed].nil?
        if snum.nil?
          found = true
          sep[:confirmed] = :street_label
        else
          if common_sep_comma(sep[:orig], snum) or search_sep_comma(snum).length == 1
            sep[:confirmed] = :street_label
            found = true

            #check for compound label (high way, express way, etc.)
            if sep[:text] == 'way'
              compound = @sep_map[i-1][:text] + sep[:text]
              if NYAConstants::LABEL_DESCRIPTORS.include? compound
                @sep_map[i-1][:confirmed] = :street_label
                @sep_map[i-1][:text] = compound
                @sep_map.delete sep
              end
            end
          end
        end
      elsif found
        break
      end
    end
  end #confirm_label

  def confirm_direction
    directions = []
    snum = search_confirmed(:street_number)
    snum = snum[:orig] if snum

    #find all directions
    @sep_map.each_with_index do |sep, i|
      if sep[:from_pattern].include? :street_direction and sep[:confirmed].nil? and not @sep_map[i+1][:confirmed] == :street_label
        snum.nil? ? directions << sep : directions << sep if common_sep_comma(snum, sep[:orig]) or search_sep_comma(snum).length == 1
      end
    end

    #chose between directions
    if directions.length == 1
      directions[0][:confirmed] = :street_direction
    elsif directions.length > 1
      short_dir_found = false
      #short dir is typically the correct one (EX: N > North)
      directions.each { |dir| short_dir_found = true if dir[:text].length < 3 }

      #remove non-short dirs
      directions.each { |dir| directions.delete(dir) if dir[:text].length > 2 } if short_dir_found

      #Typically the latter dir is the correct one
      directions.last[:confirmed] = :street_direction
    end
  end #confirm_direction

  def confirm_street_name
    num_ind = @sep_map.index search_confirmed(:street_number)
    lab_ind = @sep_map.index search_confirmed(:street_label)
    dir_ind = @sep_map.index search_confirmed(:street_direction)

    ## find start and stopping point
    name_start = nil
    name_stop = nil
    if not num_ind.nil? and not lab_ind.nil? and not dir_ind.nil? and dir_ind < lab_ind and num_ind < dir_ind #directions comes before label
      name_start = dir_ind + 1
      name_stop = lab_ind - 1

    elsif not num_ind.nil? and not lab_ind.nil?
      name_start = num_ind + 1
      @sep_map[lab_ind+1][:text].numeric? ? name_stop = lab_ind+1 : name_stop = lab_ind-1

    elsif not num_ind.nil? and not dir_ind.nil?
      if num_ind+1 != dir_ind
        name_start = num_ind + 1
        name_stop = dir_ind - 1
      end

    elsif not num_ind.nil?
      name_start = num_ind + 1
      comma = search_sep_comma(@sep_map[name_start][:orig])
      @sep_map.each_with_index { |sep, i| name_stop = i if sep[:text] == comma.last }
    end

    ## if start wasn't found
    name_start = @sep_map.index(unconfirmed_sep) if name_start.nil?

    ##if stop wasn't found
    if name_stop.nil?
      comma = search_sep_comma(@sep_comma[name_start][0])
      @sep_map.each_with_index {|sep, i| name_stop = i if sep[:orig] == comma.last}
    end

    ## Select the street name
    if not name_start.nil? and not name_stop.nil?
      (name_start..name_stop).each do |index|
        #if in same sep comma and unconfirmed
        @sep_map[index][:confirmed] = :street_name if @sep_map[index][:confirmed].nil? and common_sep_comma(@sep_map[name_start][:orig], @sep_map[index][:orig])
      end
    else
      #This should only trigger if street name was not given
      raise "Erorr occured while finding street name...\nstart: #{name_start}\nstop: #{name_stop}\nfrom address #{@orig}"
    end
  end #confirm_street_name

  def confirm_city
    low_end = []
    high_end = []
    @sep_map.each_with_index do |sep, i|
      if sep[:confirmed] == :street_name or sep[:confirmed] == :street_label or sep[:confirmed] == :street_direction
        low_end << i
      elsif sep[:confirmed] == :state or sep[:confirmed] == :postal_code
        high_end << i
      end
    end

    if not low_end.max.nil? and not high_end.min.nil?
      city_start = low_end.max + 1
      city_stop = high_end.min - 1

      comma = search_sep_comma(@sep_map[city_stop][:orig])
      (city_start..city_stop).each do |index|
        if @sep_map[index][:confirmed].nil? and not @sep_map[index][:text].has_digits?
          if comma.include? @sep_map[index][:orig] #make sure they're in the same sep comma
            @sep_map[index][:confirmed] = :city
          end
        end
      end
    end
  end #confirm_city

  ###### Confirm Identity ######


  ###Standardization###
  def standardize_aliases
    @sep_map.each do |sep|
      if sep[:confirmed] == :street_number and (sep[:text].include? '-' or sep[:text].include? '/')
        clean_dash(sep)

      elsif sep[:confirmed] == :street_name and NYAConstants::NUMBER_STREET.keys.include? sep[:text]
        sep[:text] = NYAConstants::NUMBER_STREET[sep[:text]]

      elsif sep[:confirmed] == :street_direction and NYAConstants::STREET_DIRECTIONS.keys.include? sep[:text]
        sep[:text] = NYAConstants::STREET_DIRECTIONS[sep[:text]]

      elsif sep[:confirmed] == :street_label and NYAConstants::STREET_LABELS.keys.include? sep[:text]
        sep[:text] = NYAConstants::STREET_LABELS[sep[:text]]

      elsif sep[:confirmed] == :unit
        sep[:text] = sep[:text].delete '#'
        sep[:text] = sep[:text].tr('a-z', '') if sep[:text].letter_count > 1
      end
    end
  end

  def clean_dash(sep)
    dash = sep[:text].index '-'
    dash = sep[:text].index '/' if dash.nil?

    #seperate dash
    if sep[:text][0,4].numeric?
      @bus[:street_num] = sep[:text][dash,999]
      sep[:text] = sep[:text][0,dash]
    elsif sep[:text].reverse[0,4].numeric?
      @bus[:street_num] = sep[:text][0,dash]
      sep[:text] = sep[:text][dash+1,999]
    end
  end
  ######Standardization######

  def select_final_options
    @parts = {:orig => @orig}

    @sep_map.each do |sep|
      label = sep[:confirmed]
      part = sep[:text]

      if label.nil? #this part was not assigned a label
        (@bus[:nil] ||= []) << part #creates nil if not exist

      elsif @parts[label].nil? #first part with that label added
        @parts[label] = part

      else #label already exists
        label == :street_direction ? @parts[label] = "#{@parts[label]}#{part}" : @parts[label] = "#{@parts[label]} #{part}"
      end
      @parts[:bus] = @bus
    end
  end #select_final_options

  ###Check Requirements###

  def check_requirements
    #if there is no unit but an extra part to the street_number...
    if @parts[:unit].nil? and not @bus[:street_num].nil?
      @parts[:unit] = @bus[:street_num] if @bus[:street_num].numeric?
    end
  end #check_requirements

  ######Check Requirements######

  def unconfirmed_sep
    @sep_map.each { |sep| return sep if sep[:confirmed].nil? }
  end

  def common_sep_comma(text1, text2)
    @sep_comma.each {|comma| return true if comma.include? text1 and comma.include? text2 }
    return false
  end

  def search_sep_comma(text)
    @sep_comma.each {|comma| return comma if comma.include? text}
    []
  end

  def search_confirmed(partId)
    @sep_map.each {|sep| return sep if sep[:confirmed] == partId }
    nil
  end

  def array_value_instring(array, str=@str)
    array.each { |value| value.split(' ').each { |word| return true if str.include? word } }
    # array.each do |value|
    #   value.split(' ').each { |word| return true if str.include? word}
    # end
    false
  end

end #NYIdentifier class
