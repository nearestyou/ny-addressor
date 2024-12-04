# frozen_string_literal: true

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
    dupe = match(/(.+)\1+/)

    until unsearched.empty?
      return searched + unsearched unless dupe

      location = unsearched.index(dupe[0])
      searched += unsearched[0..location - 1] if location > 0
      searched += if dupe[0].squeeze.length > 1 && dupe[0].has_letters?
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
