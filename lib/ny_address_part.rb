# frozen_string_literal: true

if ENV['LOCAL_DEPENDENCIES']
  load 'lib/constants.rb'
  load 'lib/extensions.rb'
else
  require 'constants.rb'
  require 'extensions.rb'
end

# Address Part
class NYAddressPart
  attr_reader :from_pattern, :from_position, :from_comma, :from_all, :text, :typified, :comma_block, :position
  attr_accessor :confirmed

  def initialize(word)
    @text = word
    @typified = word.typify
    pattern_options

    @comma_block = nil
  end

  def to_s
    output = "Address Part: (\nText: #{@text}\nForm: #{@typified}"
    output += "\nAll: #{@from_all}" if @from_all
    output += "\nPositional: #{@from_position}" if @from_position
    output += "\nPaternal: #{@from_pattern}" if @from_pattern
    output += "\nComma: #{@from_comma}" if @from_comma
    output += "\n)\n"
    output
  end

  def consolidate_options
    @from_all = @from_pattern
    @from_all &= @from_position if @from_position
    @from_all &= @from_comma if @from_comma
    @from_all
  end

  # @param comma - index of the comma group
  # @param comma_count - how many comma groups are there?
  def comma_options(comma, comma_count)
    @comma_block = comma

    @from_comma =
      case comma_count
      when 3
        case comma
        when 0
          %i[street_number street_name street_direction street_label unit]
        when 1
          %i[unit city state postal]
        when 3
          %i[city state postal country]
        end

      when 4
        case comma
        when 0
          %i[street_number street_name street_direction street_label unit]
        when 1
          %i[unit city state]
        when 2
          %i[city state postal]
        when 3
          %i[state postal country]
        end

      when 5
        case comma
        when 0
          %i[street_number street_name street_direction street_label unit]
        when 1
          %i[unit city]
        when 2
          %i[city state]
        when 3
          %i[state postal]
        when 4
          %i[postal country]
        end

      when 6
        case comma
        when 0
          %i[street_number street_name street_direction street_label unit]
        when 1
          %i[unit]
        when 2
          %i[city]
        when 3
          %i[state]
        when 4
          %i[postal]
        when 5
          %i[country]
        end

      else
        %i[street_number street_name street_direction street_label unit city state postal country default]
      end
  end

  def position_options(pos, num_parts)
    @position = pos
    @from_position =
      case pos
      when 0
        %i[street_number street_name unit]
      when 1
        %i[street_number street_name street_direction street_label unit]
      when 2
        %i[street_number street_name street_label unit street_direction]
      when 3
        %i[street_name street_label unit street_direction city state]
      when num_parts - 4
        %i[city state street_direction street_label unit postal]
      when num_parts - 3
        %i[city state postal]
      when num_parts - 2
        %i[city state postal country]
      when num_parts - 1
        %i[state postal country]
      else
        %i[default street_number street_name street_label street_direction unit city state postal country]
      end
  end

  def pattern_options
    @from_pattern = []
    @from_pattern << :state if NYAConstants::STATE_DESCRIPTORS.include? @text
    @from_pattern << :postal if @text.has_digits?
    @from_pattern << :country if @text.alphabetic?
    @from_pattern
  end
end
