# frozen_string_literal: true

# Extend string class
class String
  def typify
    gsub(/[0-9]/, '|').gsub(/[a-zA-Z]/, '=')
  end

  def clean
    self
      &.gsub(/\s*\(.+\)/, '') # https://stackoverflow.com/questions/8708515/ruby-rails-remove-text-inside-parentheses-from-a-string
      &.delete("'")
      &.delete(".")
      &.downcase
      &.gsub("\u00A0", ' ')
      &.gsub(/\s+/, ' ') # remove multiple spaces in a row
      &.strip
  end

  # Standardize strings for comparison testing
  def standardize
    clean.gsub(/[-\s.#]/, '')
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
    match(/[a-zA-Z]/) ? true : false
  end

  def letter_count
    gsub(/[^a-zA-Z]/, '').length
  end

  def digit_count
    split('').select(&:numeric?).length
  end

  def mostly_numeric?
    digit_count > letter_count
  end

  def mostly_letters?
    !mostly_numeric?
  end

  def strip_digits
    gsub(/[0-9]/, '')
  end

  def strip_letters
    gsub(/[a-zA-Z]/, '')
  end

  # https://stackoverflow.com/questions/7184123/check-if-string-is-repetition-of-an-unknown-substring
  # , Washington, DC 20500, Washington, DC 20500, Washington, DC 20500, Washington, DC 20500 -> , Washington, DC 20500,
  def unrepeat
    searched = ''
    unsearched = dup
    # regex = /(.+)\1+/ # basic matching
    regex = /
      (^|\b|, )       # word boundary or comma + space
      (.+?)           # Repeating string
      (,\s*|\s+)\2    # Check for repeating string after a delimiter
      ($|\b|,)        # Match to the end of a word boundary
    /x
    dupe = match(regex)

    until unsearched.empty?
      return searched + unsearched unless dupe

      location = unsearched.index(dupe[0])
      searched += unsearched[0..location - 1] if location > 0

      # Do not collapse 'unit A1010'
      long_enough = dupe[0].squeeze.length > 1
      not_a_number = dupe[0].mostly_letters? || dupe[0].split(' ').length > 2
      not_a_separator = dupe[0].strip != ','
      safe_to_collapse = long_enough && not_a_number && not_a_separator

      searched += if safe_to_collapse
                    dupe[1] + dupe[2] # delimiter + repeating string
                  else
                    dupe[0]
                  end
      unsearched = unsearched[location + dupe[0].length..]
      dupe = unsearched.match(regex)
    end
    searched
  end
end
