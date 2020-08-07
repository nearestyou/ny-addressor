class AddressorUtils
class << self

def typify(str)
  str.gsub(/[0-9]/,'|').gsub(/[a-zA-Z]/,'=')
end

def string_inclusion(str1, str2, numeric_failure = false)
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

def determine_state(state_name, postal_code = nil)
  if postal_code
  else
    return NYAConstants::US_STATES[state_name] if NYAConstants::US_STATES[state_name]
    return NYAConstants::CA_PROVINCES[state_name] if NYAConstants::CA_PROVINCES[state_name]
    return 'ER'
  end
end

def comp(parts1, parts2, comparison_keys = [:street_number, :street_name, :postal_code])
  return 0 if parts1.nil?
  return 0 if parts2.nil?
  sims = 0
  comparison_keys.each do |k|
    sims += 1 if parts1[k] == parts2[k]
  end
  sims
end

end
end
