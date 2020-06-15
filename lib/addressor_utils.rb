class AddressorUtils
class << self

def typify(str)
  str.gsub(/[0-9]/,'|').gsub(/[a-zA-Z]/,'=')
end

end
end
