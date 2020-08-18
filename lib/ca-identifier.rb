class CAIdentifier < NYIdentifier
  def initialize(str = nil)
    super(str)
    identify
  end #init

  def identify
    check_compound_prov
    super
    identify_all_by_pattern
    consolidate_identity_options
    confirm_identity_options
    standardize_aliases
    select_final_options
    check_requirements
  end #identify

  def check_compound_prov
    providences = NYAConstants::CA_COMPOUND_PROVINCES
    providences.keys.map(&:downcase).each {|key| @str = @str.gsub(key, providences[key.split.map(&:capitalize).join(' ')].downcase) if @str.include? key }
  end

  ###Pattern Options###
  def identify_all_by_pattern
    @sep_map.each_with_index do |part, i|
      @sep_map[i][:from_pattern] = pattern_options(part)
    end
  end#Identify all by pattern

  def pattern_options(part)
    opts = super
    opts << :state if potential_state(part)
    opts << :postal_code if potential_postal_code(part)
    opts << :country if potential_country(part)
    opts
  end#pattern options

  def potential_state(part) #providence
    NYAConstants::CA_DESCRIPTORS.include? part[:text]
  end

  def potential_postal_code(part)
    return true if part[:typified] == '=|=|=|'
    return true if part[:typified] == '=|='
    return true if part[:typified] == '|=|'
    false
  end

  def potential_country(part)
    part[:text] == 'ca' or part[:text] == 'canada'
  end

  ######Pattern Options######

  def standardize_aliases
    super
    @sep_map.each do |sep|

      case sep[:confirmed]
      when :state
        #If theres a full providence, abrev it
        prov = NYAConstants::CA_PROVINCES
        sep[:text] = prov[sep[:text].capitalize].downcase if prov.keys.map(&:downcase).include? sep[:text]

      when :postal_code
        sep[:text] = sep[:text].delete(' ')

      end #case sep[:confirmed]

      #Replace Saint with Ste
      NYAConstants::CA_SAINTS.each { |st| sep[:text] = sep[:text].gsub(st, 'ste') if sep[:text] == st or sep[:text].include? "#{st}." or sep[:text].include? "#{st}-"} if sep[:confirmed] != :street_label and sep[:text].include? 's'
    end
  end

end #CAIdentifier
