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
    states.keys.map(&:downcase).each {|key| @str = @str.gsub(key, states[key.split.map(&:capitalize).join(' ')].downcase) if @str.include? key }
  end

  ###Pattern Options###
  def identify_all_by_pattern
    @sep_map.each_with_index do |part, i|
      @sep_map[i][:from_pattern] = pattern_options(part)
    end
  end

  def pattern_options(part)
    opts = super
    opts << :unit if potential_unit(part)
    opts << :state if potential_state(part)
    opts << :postal_code if potential_postal_code(part)
    opts << :country if potential_country(part)
    opts
  end

  def potential_unit(part)
    return true if super
    return true if part[:text].include? 'ste' or part[:text].include? 'suite'
    return false
  end

  def potential_state(part)
    NYAConstants::US_DESCRIPTORS.include? part[:text]
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



  def standardize_aliases
    super
    @sep_map.each do |sep|
      case sep[:confirmed]
      when :state
        #If there's a full state, abrev it
        states = NYAConstants::US_STATES
        sep[:text] = states[sep[:text].capitalize].downcase if states.keys.map(&:downcase).include? sep[:text]

      when :postal_code
        #If there's a o in the zipcode, remove it
        sep[:text] = sep[:text].gsub('o', '0') if sep[:text].include? 'o'

        #If there is a zip extension, remove it
        sep[:text] = sep[:text][0..4] if sep[:text].length > 5
      end
    end
  end

  def check_requirements
    super
    # Remove duplicate city
    @parts[:city] = @parts[:city].split(' ').uniq.join(' ') if not @parts[:city].nil?
  end


end #USIdentifier
