# frozen_string_literal: true

require 'byebug'
# Extend string class
class String
  def typify
    gsub(/[0-9]/, '|').gsub(/[a-zA-Z]/, '=')
  end

  def clean
    self&.gsub(/\s*\(.+\)/, '')&.gsub(',', ' ')&.delete("'")&.downcase&.gsub("\u00A0", ' ')
    # regex: https://stackoverflow.com/questions/8708515/ruby-rails-remove-text-inside-parentheses-from-a-string
  end

  # Standardize strings for comparison testing
  def standardize
    clean.delete(' ').delete('-').delete('.')
  end

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
    # alphabet = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
    # split('').each { |char| return true if alphabet.include? char }
    match(/[a-zA-Z]/) ? true : false
  end

  def letter_count
    split('').reject(&:numeric?).length
  end

  def digit_count
    split('').select(&:numeric?).length
  end

  # https://stackoverflow.com/questions/7184123/check-if-string-is-repetition-of-an-unknown-substring
  # , Washington, DC 20500, Washington, DC 20500, Washington, DC 20500, Washington, DC 20500 -> , Washington, DC 20500,
  # def unrepeat
  #   n = size
  #   newstr = dup
  #   n.times do |i|
  #     newstr = newstr[-1] + newstr[0..-2]
  #     return self[0..i + 1] if newstr == self
  #   end
  # end
  def unrepeat
    searched = ''
    unsearched = dup
    dupe = match(/(.+)\1+/)
    # Dupe[0] = pattern found, [1] group found

    until unsearched.empty?
      return searched + unsearched unless dupe

      location = unsearched.index(dupe[0])
      searched += unsearched[0..location - 1] if location > 0
      searched += if dupe[0].squeeze.length > 1 && dupe[0].has_letters? # &&
                    # ([' ', ',', '.'].include?(dupe[0][0]) || dupe[1].length > 8)
                    dupe[1]
                  else
                    dupe[0]
                  end
      unsearched = unsearched[location + dupe[0].length..]
      dupe = unsearched.match(/(.+)\1+/)
    end
    searched
  end
end
