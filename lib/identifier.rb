class NYIdentifier
attr_accessor :str, :sep, :sep_map, :bus
  def initialize(str = nil)
    @orig = str
    @str = str
    @bus = {}
  end

  # def identifications
  #   identify
  #   { sep: @sep, sep_map: @sep_map, sep_comma: @sep_comma, bus: @bus, parts: @parts }
  # end

  def identify
    pre_extra
    create_sep_comma
    extra_sep_comma
    seperate
    post_extra
    #update_sep_comma
    create_sep_map
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
      @sep_comma.push comma.split(' ')
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
    @sep_map = @sep.map{|part| {text:part, typified:AddressorUtils.typify(part)}}
  end

end #NYIdentifier class
