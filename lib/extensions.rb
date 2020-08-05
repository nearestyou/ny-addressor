class String
  def numeric?
    Float(self) != nil rescue false
  end

  def has_digits?
    self.count("0-9") > 0
  end

  def has_letters?
    alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    self.split("").each {|char| return true if alphabet.include? char}
    false
  end
end
