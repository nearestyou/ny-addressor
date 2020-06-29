class String
  def numeric?
    Float(self) != nil rescue false
  end

  def has_digits?
    self.count("0-9") > 0
  end
end
