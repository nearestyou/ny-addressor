require 'street_address'

class NYAddressor

  def initialize(str)
    @str = str
    parse
  end

  def parse(standardize = true)
    begin
      address = StreetAddress::US.parse(scrub(@str))
      if standardize
        address.street&.downcase!
        address.street = ordinalize_street(address.street)
        address.street_type&.downcase!
        address.unit&.downcase!
        address.unit_prefix&.downcase!
        address.suffix&.downcase!
        address.prefix&.downcase!
        address.suffix ||= address.prefix
        address.city&.downcase!
        address.state&.downcase!
      end
      @parsed = address
    rescue
      @parsed = nil
    end
  end

  def city
    @parsed.city
  end

  def state
    @parsed.state
  end

  def zip
    @parsed.postal_code
  end

  def construct(line_no = nil)
    return nil if @parsed.nil?
    addr = ''
    if (line_no.nil? || line_no == 1)
      addr += "#{@parsed.number} #{@parsed.street&.capitalize} #{@parsed.street_type&.capitalize}"
      addr += ' ' + @parsed.suffix.upcase if @parsed.suffix.present?
      addr += ', ' + @parsed.unit_prefix.capitalize + (@parsed.unit_prefix == '#' ? '' : ' ') + @parsed.unit.capitalize if @parsed.unit.present? 
    end
    if (line_no.nil? || line_no == 2)
      addr += ", #{@parsed.city.capitalize}, #{@parsed.state.upcase} #{@parsed.postal_code}#{'-' if @parsed.postal_code_ext.present?}#{@parsed.postal_code_ext}"
    end
    addr
  end

  def hash
    return nil if @parsed.nil?
    Digest::SHA256.hexdigest(construct)[0..23]
  end

  def eq(parsed_address, display = false)
    return nil if @parsed.nil?
    # for displaying errors (display ? puts(parsed_address, @parsed) : false)
    return false if @parsed.number != parsed_address.number
    return false if @parsed.postal_code != parsed_address.postal_code
    return false if @parsed.street != parsed_address.street
    return false if @parsed.unit != parsed_address.unit
    return false if @parsed.city != parsed_address.city
    return false if @parsed.street_type != parsed_address.street_type
    return true
  end

  def comp(parsed_address)
    return nil if @parsed.nil?
    sims = 0
    sims += 1 if @parsed.number == parsed_address.number
    sims += 1 if @parsed.street == parsed_address.street
    sims += 1 if @parsed.postal_code == parsed_address.postal_code
    sims
  end

  def ordinalize_street(street)
    {
      'first' => '1st', 'second' => '2nd', 'third' => '3rd', 'fourth' => '4th', 'fifth' => '5th', 'sixth' => '6th', 'seventh' => '7th', 'eighth' => '8th', 'ninth' => '9th', 'tenth' => '10th', 'eleventh' => '11th', 'twelfth' => '12th'
    }[street] || street
  end

  def remove_periods(str)
    str.gsub('.','')
  end

  def remove_country(str)
    if ['0','1','2','3','4','5','6','7','8','9'].include?(str[-1])
      str
    else
      str.split(',')[0..-2].join(',')
    end
  end

  def remove_cross_street(str)
    str.gsub(/\([^\)]+\)/,'')
  end

  def remove_many_spaces(str)
    str.gsub(/[ \t]+/,' ')
  end

  def remove_duplicate_entries(str)
    str.split(',').map{|element| element.strip}.uniq.join(', ')
  end

  def scrub(str)
    remove_many_spaces(
      remove_cross_street(
        remove_duplicate_entries(
          remove_periods(
            remove_country(
              str
            )
          )
        )
      )
    )
  end

end
