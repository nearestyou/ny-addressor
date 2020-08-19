class IRIdentifier < NYIdentifier

  def pattern_options(part)
    opts = super
    opts << :state if potential_state(part)
    opts << :postal_code if potential_postal_code(part)
    opts << :country if potential_country(part)
    opts
  end

  def potential_state(part) #county
    return true if NYAConstants::IR_COUNTIES.include? part[:text]
  end

  def potential_postal_code(part)
    return true if array_value_instring(NYAConstants::IR_POSTAL_CODES, part[:typified])
  end

  def potential_country(part)
    return true if part[:text] == 'ireland' or part[:text] == 'united' or part[:text] == 'kingdom' or part[:text] == 'uk'
  end
  ######Pattern Options######

  def location_options(part, i, nParts)
    case i
    when 0
      [:street_number, :street_name, :unit]
    when 1
      [:street_number, :street_name, :street_direction, :street_label]
    when 2
      [:street_number, :street_name, :street_label, :street_unit, :street_direction]
    when nParts - 4
      [:street_name, :street_label, :street_direction, :unit, :state, :postal_code]
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

  def confirm_country
    super
    @sep_map[-2][:confirmed] = :country if @sep_map[-2][:from_pattern].include? :country
  end

  def confirm_postal_code
    @sep_map.reverse.each do |sep|
      sep[:confirmed] = :postal_code if sep[:in_both].include? :postal_code
    end
  end

end #IRIdentifier
