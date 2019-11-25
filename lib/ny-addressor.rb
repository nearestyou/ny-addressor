require 'street_address'
require 'digest'

class NYAddressor

  PLACEHOLDERS = {street_number: '000000', unit: '0XYZ'}

  def initialize(str)
    @monitor = false
    @orig = str # to keep an original
    @str = str
    @bus = {}
    if str.nil?
      @parsed = nil
    else
      set_locale
      pre_scrub_logic
      scrub
      post_scrub_logic
      parse
      undo_logic
    end
  end

  def basic
    StreetAddress::US.parse(@str)
  end

  def monitor(set_state = true)
    @monitor = set_state
  end

  def str
    @str
  end

  def orig
    @orig
  end

  def reset_str(str = @orig)
    @str = str
  end

  def typify
    @typified = @str.gsub(/[0-9]/,'|').gsub(/[a-zA-Z]/,'=')
  end

  def set_locale
    typify
    @locale = if @typified.include?('=|= |=|')
      :ca 
    else
      :us
    end
  end

  def pre_scrub_logic
    case @locale
    when :ca
      start = @typified.index('=|= |=|')
      @bus[:postal_code] = @str.slice(start..(start + 6))
      parts = @str.split(@bus[:postal_code])
      @str = parts.first + '99999' + (parts.length == 2 ? parts.last : '')
    end
    shunt_wi_address(:dump)
  end

  def post_scrub_logic
    case @locale
    when :ca
      arr = @str.split(',')
      @bus[:prov] = arr[-2]
      arr[-2] = 'MN'
      @str = arr.join(',')
    end
  end

  def undo_logic
    case @locale
    when :ca
      if @parsed
        @parsed.state = @bus[:prov].downcase
        @parsed.postal_code = @bus[:postal_code]
      end
    end
    shunt_wi_address(:load)
    octothorpize_ste_units(:undo)
  end

  def shunt_wi_address(action)
    if action == :dump
      if @str.index(/[NEWSnews]\d+([NEWSnews]\d+)?/)
        street_number = @str.gsub(',',' ').split(' ').select{|part| part =~ /[NEWSnews]\d+([NEWSnews]\d+)?/}.first
        @bus[:street_number] = street_number
        @str = @str.gsub(street_number, PLACEHOLDERS[:street_number])
        typify
      end
    else
      if @bus[:street_number]
        @str = @str.gsub(PLACEHOLDERS[:street_number], @bus[:street_number])
        typify
      end
    end
  end

  def parse(standardize = true)
    case @locale
    when :ca
      parse_us(standardize)
    else
      parse_us(standardize)
    end
  end

  def parse_us(standardize = true)
    begin
      address = StreetAddress::US.parse(@str)
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
        address.state = @bus[:state] if @bus[:state]
        address.state&.downcase!
        address.postal_code = @bus[:zip] if @bus[:zip]
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

  def construct(opts = {})
    opts = {line_no: nil, fix: :suffix, include99999: true, exclude_unit: false}.merge(opts)
    return nil if @parsed.nil?
    addr = ''
    if (opts[:line_no].nil? || opts[:line_no] == 1)
      addr += "#{@parsed.number} #{(opts[:fix] == :prefix and @parsed.suffix) ? @parsed.suffix&.upcase + ' ' : ''}#{@parsed.street&.capitalize} #{@parsed.street_type&.capitalize}"
      addr += ' ' + @parsed.suffix&.upcase unless (@parsed.suffix.nil? or opts[:fix] == :prefix)
      addr += ', ' + @parsed.unit_prefix&.capitalize + (@parsed.unit_prefix == '#' ? '' : ' ') + @parsed.unit&.capitalize unless (@parsed.unit.nil? or opts[:exclude_unit])
    end
    if (opts[:line_no].nil? || opts[:line_no] == 2)
      addr += ", #{@parsed.city&.capitalize}, #{@parsed.state&.upcase} #{@parsed.postal_code if (@parsed.postal_code.to_s != '99999' or opts[:include99999])}"
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

  def unitless_hash
    return nil if @parsed.nil?
    Digest::SHA256.hexdigest(construct({exclude_unit: true}))[0..23]
  end

  def sns
    @parsed ? ([@bus[:street_number] || @parsed.number || '',@parsed.street || '',@bus[:state] || @parsed.state].join('')&.downcase&.gsub('-','') || '') : ''
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

  def remove_periods
    @str = @str.gsub('.','')
  end

  def remove_country
    splt = @str.split(',').map(&:strip)
    splt_typ = @typified.split(',').map(&:strip)
    if zip_ndx = splt_typ.index('|||||')
      @str = splt[0..zip_ndx].join(',')
    elsif zip_ndx = splt_typ.index('== |||||')
      @str = splt[0..zip_ndx].join(',')
    elsif st_ndx = splt_typ.index('==')
      @str = splt[0..st_ndx].join(',')
    elsif possible_second_line = splt_typ.select{|el| el[-10..-1] == '= == |||||'}.last
      psl_ndx =splt_typ.index(possible_second_line)
      @str = splt[0..psl_ndx].join(',')
    end
    #if @str.count(',') >= 3 # in case ZIP is missing
    #  splt = @str.split(',').map(&:strip)
    #  splt_typ = @typified.split(',').map(&:strip)
    #  splt = splt[0..-2] unless splt_typ[-1][-1] == '|'
    #  @str = splt.join(',')
    #  puts @str
    #  #@str = @str.split(',')[0..-2].join(',') unless ['0','1','2','3','4','5','6','7','8','9'].include?(@str[-1])
    #end
  end

  def remove_cross_street
    @str = @str.gsub(/\([^\)]+\)/,'')
  end

  def remove_many_spaces
    @str = @str.gsub(/[ \t]+/,' ')
  end

  def remove_duplicate_entries
    @str = @str.split(',').map(&:strip).uniq.join(', ')
  end

  def guarantee_zip
    @str = @str + ' 99999' unless @typified[-4..-1] == '||||'
  end

  def numerify_zip
    typ = @str.gsub(/[0-9Oo]/,'|')
    determination = [typ,@typified].map{|metric| metric.split(',').map{|i| i.split(' ')}.flatten.count('|||||')}
    if determination.first != determination.last
      rev_typ = typ.reverse
      rev_str = @str.reverse
      ndx = rev_typ.index('|||||')
      if ndx == 0
        @str = (rev_str[0..4].gsub(/[Oo]/,'0') + rev_str[5..-1]).reverse
      else
        @str = (rev_str[0..(ndx - 1)] + rev_str[ndx..(ndx + 4)].gsub(/[Oo]/,'0') + rev_str[(ndx + 5)..-1]).reverse
      end
    end
  end

  def remove_extra_commas
    @str = @str.split(',').select{|i| !i.nil? and !i.empty?}.join(',')
  end

  def remove_zip_extension
    ['|||||-||||','|||||||||'].each do |pattern|
      @typified.scan(pattern).count.times do |i|
        ndx = @typified.index(pattern)
        @str[ndx..(ndx + pattern.length)] = @str[ndx..(ndx + 4)]
        typify
      end
    end
  end

  def abbreviate_state
    unless @str[-10] == ' ' # This is the prestate character
      case @locale
      when :us
        state_list = US_STATES
      when :ca
        state_list = CA_PROVINCES
      end
      zipless_str = @str[0..-8].downcase
      states = state_list.keys.select{|full_name| zipless_str.end_with?(full_name.downcase)}
      if state = states.max_by{|state| state.length}
        case @locale
        when :us
          @str = @str[0..(-8 - state.length)] + state_list[state] + @str[-7..-1] 
        when :ca
          @str = @str[0..(-8 - state.length)] + 'MN' + @str[-7..-1] 
          @bus[:state] = state_list[state]
        end
      end
    end
  end

  def guarantee_prezip_comma
    case @typified[-8..-1] 
    when '== |||||'
      @str = @str[0..-7] + ',' + @str[-6..-1] 
    when '==,|||||'
      @str = @str[0..-6] + ' ' + @str[-5..-1] 
    end
  end

  def guarantee_prestate_comma
    if @typified[-11..-1] == ', ==, |||||'
    elsif @typified[-10..-1] == ',==, |||||'
    elsif @typified[-11..-1] == '= ==, |||||'
      @str = @str[0..-11] + ',' + @str[-10..-1] 
    end
  end

  def remove_numbers_from_city
    arr = @str.split(',')
    arr[-3] = arr[-3].gsub(/[0-9]/,'').strip if arr[-3]
    @str = arr.join(',')
  end

  def guarantee_street_type
    @str = @str.gsub(/express way/i,'Expy').gsub(/expressway/i,'Expy').gsub(/exwy/i,'Expy').gsub(/expwy/i,'Expy') if @str.downcase.include?('ex')
    arr = @str.split(',')
    if arr.length > 1 and arr[0].split(' ').length < 3
      arr[0] = arr[0] + ' st'
      @str = arr.join(',')
    end
  end

  def remove_two_locations
    if @str.include?('&')
      words = @str.split(' ')
      if words[1] == '&'
        @str = words[2..-1].join(' ')
      elsif words[0].include?('&')
        first_word = words[0].split('&')
        @str = ([first_word.last] + words[1..-1]).join(' ')
      end
    end
  end

  def scrub(functions = nil)
    (functions || [ # The order of these is important!
      :remove_two_locations,
      :remove_extra_commas,
      :remove_zip_extension,
      :remove_duplicate_entries,
      :numerify_zip,
      :remove_periods,
      :remove_country,
      :guarantee_zip,
      :remove_cross_street,
      :remove_many_spaces,
      :guarantee_street_type,
      :guarantee_prezip_comma,
      :abbreviate_state,
      :guarantee_prestate_comma,
      :remove_numbers_from_city,
      :remove_duplicate_entries, # Yup, this has to be in here more than once.
      :to_array_scrub_and_back
    ]).each do |func|
      begin
        send(func)
        typify
        if @monitor
          puts func
          puts @typified
          puts @str
        end
      rescue Exception => e
        puts "#{func}: #{@orig} - #{e}"
      end
    end
  end

  def show_state
    puts @str + @typified
  end

  def remove_state_from_city(arr)
    arr[-3] = arr[-3][0..-4] if arr[3] and arr[-3][-3..-1].downcase == " #{arr[-2].downcase}"
    arr
  end

  def guarantee_second_line_unit_designator(arr)
    if ['1','2','3','4','5','6','7','8','9','0'].include?(arr[1][0])
      arr[1] = '#' + arr[1]
    end
    arr
  end

  def move_leading_unit_designator(arr)
    if @locale == :ca
      if arr[0].include?('-')
        first_entry = arr[0].split('-')
        arr = [first_entry.last, '#' + first_entry.first] + arr[1..-1]
      elsif arr[0].include?('/')
        first_entry = arr[0].split('/')
        arr = [first_entry.last, '#' + first_entry.first] + arr[1..-1]
      else
        ### this is meant to pick up units separated by spaces, but will pick up a lot of false positives, so we're leaving it off.
        #first_entry_word_types = arr[0].gsub(/[0-9]/,'|').split(' ') 
        #if first_entry_word_types.select{|word| word[0] == '|'}.count == 2
        #  if first_entry_word_types[0].split(//).uniq == ['|'] and first_entry_word_types[1].split(//).uniq == ['|']
        #    first_entry_words = arr[0].split(' ') 
        #    arr = [first_entry_words[1..-1].join(' '), '#' + first_entry_words.first] + arr[1..-1]
        #    puts arr
        #  end
        #end
      end
    end
    arr
  end

  def octothorpize_ste_units(arr)
    if(arr == :undo)
      if @str.include?(PLACEHOLDERS[:unit])
        @str.gsub(PLACEHOLDERS[:unit], @bus[:unit])
        typify
      end
    else
      if arr.first.downcase.include?(" ste ")
        arr[0] = arr[0].gsub(/ ste /i,' #').strip
        part_after_number = arr[0].split('#').last
        unless ['1','2','3','4','5','6','7','8','9','0'].include?(part_after_number[0])
          after_number_words = part_after_number.split(' ')
          @bus[:unit] = after_number_words.first
          if after_number_words.count == 1
            arr[0] = [arr[0].split('#').first, PLACEHOLDERS[:unit]].join('#')
          else
            after_number_words[0] = PLACEHOLDERS[:unit]
            arr[0] = [arr[0].split('#').first, after_number_words.join(' ')].join('#')
          end
        end
      end
      return arr
    end
  end

  def to_array_scrub_and_back(functions = nil)
    arr = @str.split(',').map(&:strip)
    (functions || [ # The order of these is important!
      :octothorpize_ste_units,
      :guarantee_second_line_unit_designator,
      :move_leading_unit_designator,
      :remove_state_from_city,
    ]).each{|func| arr = send(func, arr)}
    @str = arr.join(',')
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

  def self.determine_state(state_name, zip = nil)
    if zip
    else
      return US_STATES[state_name] if US_STATES[state_name]
      return CA_PROVINCES[state_name] if CA_PROVINCES[state_name]
      return 'ER'
    end
  end

  CA_PROVINCES ||= {
    "Ontario" => "ON",
    "Quebec" => "QC",
    "Nova Scotia" => "NS",
    "New Brunswick" => "NB",
    "Manitoba" => "MB",
    "British Columbia" => "BC",
    "Prince Edward Island" => "PE",
    "Saskatchewan" => "SK",
    "Alberta" => "AB",
    "Newfoundland and Labrador" => "NL",
    "Northwest Territories" => "NT",
    "Yukon" => "YT",
    "Nunavut" => "NU",
  }
  US_STATES ||= {
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
