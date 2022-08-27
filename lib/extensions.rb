# frozen_string_literal: true

# Extend string class
class String
  def numeric?
    self[/[0-9]+/] == self
  end

  def alphabetic?
    self[/[a-zA-Z]+/] == self
  end

  def has_digits?
    count('0-9').positive?
  end

  def has_letters?
    alphabet = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
    split('').each { |char| return true if alphabet.include? char }
    false
  end

  def letter_count
    split('').reject(&:numeric?).length
  end

  def digit_count
    split('').select(&:numeric?).length
  end
end
