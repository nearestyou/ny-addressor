require 'street_address'
require 'digest'

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
        address.suffix&.downcase!           # Don't tell me this isn't glorious
        address.prefix&.downcase!           #
        address.suffix ||= address.prefix   #
        address.prefix ||= address.suffix   #
        address.city&.downcase!
        address.state&.downcase!
      end
      @parsed = address
    rescue
      @parsed = nil
    end
  end

  def parsed
    @parsed
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

  def construct(line_no = nil, fix = :suffix, include99999 = true)
    return nil if @parsed.nil?
    addr = ''
    if (line_no.nil? || line_no == 1)
      addr += "#{@parsed.number} #{(fix == :prefix and @parsed.suffix) ? @parsed.suffix.upcase + ' ' : ''}#{@parsed.street&.capitalize} #{@parsed.street_type&.capitalize}"
      addr += ' ' + @parsed.suffix.upcase unless (@parsed.suffix.nil? or fix == :prefix)
      addr += ', ' + @parsed.unit_prefix.capitalize + (@parsed.unit_prefix == '#' ? '' : ' ') + @parsed.unit.capitalize unless @parsed.unit.nil? 
    end
    if (line_no.nil? || line_no == 2)
      addr += ", #{@parsed.city.capitalize}, #{@parsed.state.upcase} #{@parsed.postal_code if (@parsed.postal_code.to_s != '99999' or include99999)}"
    end
    addr
  end

  def hash
    return nil if @parsed.nil?
    Digest::SHA256.hexdigest(construct)[0..23]
  end

  def hash99999 # for searching by missing/erroneous ZIP
    return nil if @parsed.nil?
    Digest::SHA256.hexdigest(construct[0..-6] + "99999")[0..23]
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
    return 0 if @parsed.nil?
    return 0 if parsed_address.nil?
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
    elsif str.count(',') < 3 # in case ZIP is missing
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
    str.split(',').map(&:strip).uniq.join(', ')
  end

  def guarantee_zip(str)
    (str[-4..-1].gsub(/[0-9]/,'|') == '||||') ? str : (str + ' 99999')
  end

  def remove_trailing_comma(str)
    str[-1] == ',' ? str[0..-2] : str
  end

  def guarantee_prezip_comma(str)
    (str[-8..-1].gsub(/[0-9]/,'|').gsub(/[a-zA-Z]/,'=') == '== |||||') ? str[0..-7] + ',' + str[-6..-1] : str
  end

  def guarantee_prestate_comma(str)
    (str[-11..-1].gsub(/[0-9]/,'|').gsub(/[a-zA-Z]/,'=') == ', ==, |||||') ? str : str[0..-11] + ',' + str[-10..-1]
  end

  def remove_numbers_from_city(str)
    arr = str.split(',')
    arr[-3] = arr[-3].gsub(/[0-9]/,'').strip
    arr.join(',')
  end

  def scrub(str, functions = nil)
    (functions || [ # The order of these is important!
      :remove_trailing_comma,
      :remove_country,
      :remove_duplicate_entries,
      :remove_periods,
      :guarantee_zip,
      :remove_cross_street,
      :remove_many_spaces,
      :guarantee_prezip_comma,
      :guarantee_prestate_comma,
      :remove_numbers_from_city,
      :remove_duplicate_entries, # Yup, this has to be in here more than once.
      :to_array_scrub_and_back
    ]).each{|func| str = send(func, str)}
    str
  end

  def remove_state_from_city(arr)
    arr[-3] = arr[-3][0..-4] if arr[-3][-3..-1].downcase == " #{arr[-2].downcase}"
    arr
  end

  def to_array_scrub_and_back(str, functions = nil)
    arr = str.split(',').map(&:strip)
    (functions || [ # The order of these is important!
      :remove_state_from_city,
    ]).each{|func| arr = send(func, arr)}
    arr.join(',')
  end

  def self.string_inclusion(str1, str2, numeric_failure = false)
    strs = [ str1.downcase.gsub(/[^a-z0-9]/, ''), str2.downcase.gsub(/[^a-z0-9]/, '') ].sort_by{|str| str.length}
    case
    when strs.last.include?(strs.first)
      return 1
    else
      if numeric_failure
        better_match = 0
        short_length = strs.first.length
        long_length = strs.last.length

        (short_length - 1).downto(1) do |n|
          0.upto(short_length - n) do |i|
            better_match = [n, better_match].max if strs.last.include?(strs.first[i..(i+n-1)])
          end
        end

        (long_length - 1).downto(1) do |n|
          break if n <= better_match
          0.upto(long_length - n) do |i|
            better_match = [n, better_match].max if strs.first.include?(strs.last[i..(i+n-1)])
          end
        end

        return better_match.to_f / short_length
      else
        return 0
      end
    end
  end

  STATES ||= {
    "Alabama" => "AL",
    "Alaska" => "AK",
    "Arizona" => "AZ",
    "Arkansas" => "AR",
    "California" => "CA",
    "Colorado" => "CO",
    "Connecticut" => "CT",
    "Delaware" => "DE",
    "Florida" => "FL",
    "Georgia" => "GA",
    "Hawaii" => "HI",
    "Idaho" => "ID",
    "Illinois" => "IL",
    "Indiana" => "IN",
    "Iowa" => "IA",
    "Kansas" => "KS",
    "Kentucky" => "KY",
    "Louisiana" => "LA",
    "Maine" => "ME",
    "Maryland" => "MD",
    "Massachusetts" => "MA",
    "Michigan" => "MI",
    "Minnesota" => "MN",
    "Mississippi" => "MS",
    "Missouri" => "MO",
    "Montana" => "MT",
    "Nebraska" => "NE",
    "Nevada" => "NV",
    "New Hampshire" => "NH",
    "New Jersey" => "NJ",
    "New Mexico" => "NM",
    "New York" => "NY",
    "North Carolina" => "NC",
    "North Dakota" => "ND",
    "Ohio" => "OH",
    "Oklahoma" => "OK",
    "Oregon" => "OR",
    "Pennsylvania" => "PA",
    "Rhode Island" => "RI",
    "South Carolina" => "SC",
    "South Dakota" => "SD",
    "Tennessee" => "TN",
    "Texas" => "TX",
    "Utah" => "UT",
    "Vermont" => "VT",
    "Virginia" => "VA",
    "Washington" => "WA",
    "West Virginia" => "WV",
    "Wisconsin" => "WI",
    "Wyoming" => "WY"
  }

end
