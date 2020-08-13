class USIdentifier < NYIdentifier
  def initialize(str = nil)
    super(str)
    identify
  end

  def identify
    condense_usa
    check_compound_state
    super
    identify_all_by_pattern
    consolidate_identity_options
    confirm_identity_options
    standardize_aliases
    select_final_options
    check_requirements
  end

  #Convert United States of America to usa
  def condense_usa
    og = @str
    us_alias = ['us', 'united states of america', 'united states']
    us_alias.each do |name|
      @str = @str.gsub(name, 'usa') if og.include? name
    end
  end

  #Looks for states like 'North Dakota' to combine them
  def check_compound_state
    states = NYAConstants::US_COMPOUND_STATES
    keys = states.keys.map(&:downcase)
    keys.each {|key| @str = @str.gsub(key, states[key.split.map(&:capitalize).join(' ')].downcase) if @str.include? key }
  end

  ###Pattern Options###
  def identify_all_by_pattern
    @sep_map.each_with_index do |part, i|
      @sep_map[i][:from_pattern] = pattern_options(part)
    end
  end

  def pattern_options(part)
    opts = super
    opts << :state if potential_state(part)
    opts << :postal_code if potential_postal_code(part)
    opts << :country if potential_country(part)
    opts
  end

  def potential_state(part)
    return true if (NYAConstants::US_STATES.keys + NYAConstants::US_STATES.values + NYAConstants::US_COMPOUND_STATES.values).map(&:downcase).include? part[:text]
    NYAConstants::US_COMPOUND_STATES.keys.map(&:downcase).each {|state| return true if state.include? part[:text] }
    return false
  end

  def potential_postal_code(part)
    return true if part[:typified] == '|||||'
    return true if part[:text].delete('-').numeric? and (part[:text].length == 9 or part[:text].length == 10)
    return true if part[:text].delete('o').numeric? and part[:text].length == 5
    false
  end

  def potential_country(part)
    part[:text] == 'usa'
  end
  ######Pattern Options######


  ###Confirm Identity###
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

  def confirm_state
    found = false
    @sep_map.reverse.each_with_index do |sep, i|
      if sep[:in_both].include? :state
        if found
          #Check for compound state
          if NYAConstants::US_COMPOUND_STATES.keys.map(&:downcase).include? "#{sep[:text]} #{@sep_map.reverse[i-1][:text]}" and @sep_map.reverse[i-1][:confirmed] == :state
            sep[:confirmed] = :state
          else
            #this method will give 'North' the :state attribute
            #so it gets removed once the actual state is found
            sep[:in_both].delete :state
          end
        else #if found
          sep[:confirmed] = :state
          found = true
        end
      end
    end
  end #confirm_state_options

  ######Confirm Identity######

  def standardize_aliases
    super
    @sep_map.each do |sep|
      case sep[:confirmed]
      when :state
        #If there's a full state, abrev it
        sep[:text] = NYAConstants::US_STATES[sep[:text].capitalize].downcase if sep[:confirmed] == :state and NYAConstants::US_STATES.keys.map(&:downcase).include? sep[:text]

      when :postal_code
        #If there's a o in the zipcode, remove it
        sep[:text] = sep[:text].gsub('o', '0') if sep[:text].include? 'o'

        #If there is a zip extension, remove it
        sep[:text] = sep[:text][0..5] if sep[:text].length > 5
      end
    end
  end

  def check_requirements
    super
    # Remove duplicate city
    @parts[:city] = @parts[:city].split(' ').uniq.join(' ') if not @parts[:city].nil?
  end


end #USIdentifier
