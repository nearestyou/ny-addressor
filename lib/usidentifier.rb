class USIdentifier < NYIdentifier
  def initialize(str = nil)
    super(str)
    identify
  end

  def identify
    super
    identify_all_by_location
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


  ###Pattern Options###
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
  ######Pattern Options######

end #USIdentifier
