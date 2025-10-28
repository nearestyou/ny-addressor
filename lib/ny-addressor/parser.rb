# frozen_string_literal: true
module NYAddressor
  class Parser
    DIRECTIONALS = {
      "n"=>"n","north"=>"n","s"=>"s","south"=>"s","e"=>"e","east"=>"e","w"=>"w","west"=>"w",
      "ne"=>"ne","northeast"=>"ne","nw"=>"nw","northwest"=>"nw","se"=>"se","southeast"=>"se","sw"=>"sw","southwest"=>"sw" }.freeze

    STREET_LABELS = %w[
      street road avenue boulevard lane drive
      court circle place terrace way highway
      parkway square loop walk trail plaza
      expressway route
    ].freeze

    # N Main St -> dir=N, name=Main, label=St
    # Main St N -> dir=N, name=Main, label=St
    # North St ->  dir=, name=North, label=St
    # @param road [String]
    # @return [Hash{Symbol=>String}]
    def self.parse_road(road)
      tokens = road.downcase.split(/\s+/)
      return { street_name: road } if tokens.empty?

      # Pick out the label
      label_index = tokens.rindex { |t| STREET_LABELS.include?(t) }
      street_label = label_index ? tokens[label_index] : nil
      tokens.delete_at(label_index) if label_index

      # Pick out the direction
      direction_prefix = tokens.size == 1 ? nil : DIRECTIONALS[tokens.first]
      direction_suffix = tokens.size == 1 ? nil : DIRECTIONALS[tokens.last]
      tokens.shift if direction_prefix
      tokens.pop if direction_suffix

      {
        street_name: tokens.join(' ').strip,
        street_label: street_label,
        street_direction: direction_suffix || direction_prefix
      }.compact
    end

    # @param raw [String]
    # @return [Hash{Symbol=>String}]
    def self.parts(raw)
      result = {}
      Postal::Parser.parse_address(raw.to_s).each do |c|
        if c[:label] == :road
          result.merge!(parse_road(c[:value]))
        else
          result[c[:label]] = c[:value]
        end
      end
      result
    end
  end
end
