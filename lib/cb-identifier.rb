class CBIdentifier < NYIdentifier

  def identify
    standardize_island
    super
  end

  def standardize_island
    # #determine which island
    island = 0
    (0..NYAConstants::CB_ISLANDS.length-1).each {|i| island = i if @str.include? NYAConstants::CB_ISLANDS[i]}
    island = 0 if island == 1 or island == 2

    #replace island with index
    @str = @str.gsub(NYAConstants::CB_ISLANDS[island], "island#{island}")
  end #standardize_island

  ###Pattern Options###

  def pattern_options(part)
    opts = super
    opts << :state if potential_state(part)
    opts << :postal_code if potential_postal_code(part)
    opts << :country if potential_country(part)
    opts
  end

  def potential_state(part)
    return true if part[:text].has_digits? and part[:text].include? 'island' and part[:text].length == 7
    return false
  end

  def potential_postal_code(part)
    return true if part[:typified] == '==||' #bermuda
    return false
  end

  def potential_country(part)
    return true if part[:text].include? 'netherl'
  end
  ######Pattern Options######

  def standardize_aliases
    super
    @sep_map.each do |sep|
      case sep[:confirmed]
      when :state
        sep[:text] = NYAConstants::CB_ISLANDS[sep[:text][-1].to_i]
      end
    end
  end #standardize_aliases

end #CBIdentifier
