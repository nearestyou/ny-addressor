# frozen_string_literal: true

# Constants
class NYAConstants

  # Words that we can assume by pattern are a state
  other_descriptors = []
  US_DESCRIPTORS = (US_STATES.keys.map(&:split).flatten + US_STATES.values).map(&:downcase).freeze
  CA_DESCRIPTORS = (CA_PROVINCES.keys.map(&:split).flatten + CA_PROVINCES.values).map(&:downcase).freeze
  UK_DESCRIPTORS = (UK_STATES.keys.map(&:split).flatten + UK_STATES.values).map(&:downcase).freeze
  AU_DESCRIPTORS = (AU_STATES.keys.map(&:split).flatten + AU_STATES.values).map(&:downcase).freeze
  STATE_DESCRIPTORS = (US_DESCRIPTORS + CA_DESCRIPTORS + UK_DESCRIPTORS + AU_DESCRIPTORS + other_descriptors).freeze

  US_ALIAS = [
    'usa',
    'us',
    'united states of america',
    'united states'
  ].freeze

  DIRECTION_DESCRIPTORS ||= (STREET_DIRECTIONS.keys + STREET_DIRECTIONS.values).freeze

  LABEL_DESCRIPTORS = (STREET_LABELS.keys + STREET_LABELS.values).freeze

  UNIT_DESCRIPTORS ||= (UNITS.keys + UNITS.values).freeze

  CB_ISLAND_NAMES = ['saint maarten', 'sint maarten', 'st maarten', 'saint martin', 'st martin', 'bermuda', 'anguilla', 'us virgin islands', 'bahamas', 'puerto rico', 'cayman islands', 'montserrat', 'british virgin islands', 'trinidad', 'tobago', 'saint vincent', 'st vincent', 'grenadines', 'saint lucia', 'st lucia', 'saint kitts', 'st kitts', 'nevis', 'aruba', 'jamaica', 'grenada', 'haiti', 'guadeloupe', 'martinique', 'saint barthelemy', 'st barthelemy', 'barbados', 'antigua']
  CB_ISLANDS = ['st', 'maarten', 'bermuda', 'anguilla', 'bvis', 'virgin', 'islands', 'cayman', 'bahamas', 'trinidad', 'cotto', 'laurel', 'santa', 'isabel', 'british', 'devonshire', 'sint']

  STANDARDIZE_ALL = {}
  STANDARDIZE_ALL.merge!(CA_PROVINCES)
  STANDARDIZE_ALL.merge!(US_STATES)
  STANDARDIZE_ALL.merge!(NUMBER_STREET)
  STANDARDIZE_ALL.merge!(STREET_DIRECTIONS)
  STANDARDIZE_ALL.merge!(STREET_LABELS)
  STANDARDIZE_ALL.merge!({'st.' => 'st'})

  STANDARDIZE_ALL.merge!(Hash[US_ALIAS.map { |us| [us, 'usa'] }])
  STANDARDIZE_ALL.merge!(Hash[POBOX_ALIAS.map { |po| [po, 'pobox'] }])

  STANDARDIZE_ALL.transform_keys!(&:downcase)
  STANDARDIZE_ALL.transform_values!(&:downcase)
end
