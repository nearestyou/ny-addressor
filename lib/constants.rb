# frozen_string_literal: true

# Constants
class NYAConstants
  CA_PROVINCES = {
    'Ontario' => 'ON',
    'Quebec' => 'QC',
    'Nova Scotia' => 'NS',
    'New Brunswick' => 'NB',
    'Manitoba' => 'MB',
    'British Columbia' => 'BC',
    'Prince Edward Island' => 'PE',
    'Saskatchewan' => 'SK',
    'Alberta' => 'AB',
    'Newfoundland and Labrador' => 'NL',
    'Northwest Territories' => 'NT',
    'Yukon' => 'YT',
    'Nunavut' => 'NU'
  }.freeze
  US_STATES = {
    'Alabama' => 'AL',
    'Alaska' => 'AK',
    'Arizona' => 'AZ',
    'Arkansas' => 'AR',
    'California' => 'CA',
    'Colorado' => 'CO',
    'Connecticut' => 'CT',
    'Delaware' => 'DE',
    'District of Columbia' => 'DC',
    'D.C.' => 'DC',
    'Florida' => 'FL',
    'Georgia' => 'GA',
    'Hawaii' => 'HI',
    'Idaho' => 'ID',
    'Illinois' => 'IL',
    'Indiana' => 'IN',
    'Iowa' => 'IA',
    'Kansas' => 'KS',
    'Kentucky' => 'KY',
    'Louisiana' => 'LA',
    'Maine' => 'ME',
    'Maryland' => 'MD',
    'Massachusetts' => 'MA',
    'Michigan' => 'MI',
    'Minnesota' => 'MN',
    'Mississippi' => 'MS',
    'Missouri' => 'MO',
    'Montana' => 'MT',
    'Nebraska' => 'NE',
    'Nevada' => 'NV',
    'New Hampshire' => 'NH',
    'New Jersey' => 'NJ',
    'New Mexico' => 'NM',
    'New York' => 'NY',
    'North Carolina' => 'NC',
    'North Dakota' => 'ND',
    'Ohio' => 'OH',
    'Oklahoma' => 'OK',
    'Oregon' => 'OR',
    'Pennsylvania' => 'PA',
    'Puerto Rico' => 'PR',
    'Rhode Island' => 'RI',
    'South Carolina' => 'SC',
    'South Dakota' => 'SD',
    'Tennessee' => 'TN',
    'Texas' => 'TX',
    'Utah' => 'UT',
    'Vermont' => 'VT',
    'Virginia' => 'VA',
    'Washington' => 'WA',
    'West Virginia' => 'WV',
    'Wisconsin' => 'WI',
    'Wyoming' => 'WY'
  }.freeze

  # Words that we can assume by pattern are a state
  other_descriptors = []
  US_DESCRIPTORS = (US_STATES.keys.map(&:split).flatten + US_STATES.values).map(&:downcase).freeze
  CA_DESCRIPTORS = (CA_PROVINCES.keys.map(&:split).flatten + CA_PROVINCES.values).map(&:downcase).freeze
  STATE_DESCRIPTORS = (US_DESCRIPTORS + CA_DESCRIPTORS + other_descriptors).freeze

  POBOX_ALIAS = [
    'po',
    'box',
    'pobox',
    'rr',
    'r.r.'
  ].freeze

  US_ALIAS = [
    'usa',
    'us',
    'united states of america',
    'united states'
  ].freeze

  NUMBER_STREET = {
    'first' => '1st',
    'second' => '2nd',
    'third' => '3rd',
    'fourth' => '4th',
    'fifth' => '5th',
    'sixth' => '6th',
    'seventh' => '7th',
    'eighth' => '8th',
    'ninth' => '9th',
    'tenth' => '10th',
    'eleventh' => '11th',
    'twelfth' => '12th'
  }.freeze

  STREET_DIRECTIONS = {
    'no' => 'n',
    'so' => 's',
    'north' => 'n',
    'south' => 's',
    'east' => 'e',
    'west' => 'w',
    'northeast' => 'ne',
    'northwest' => 'nw',
    'southeast' => 'se',
    'southwest' => 'sw'
  }.freeze
  DIRECTION_DESCRIPTORS ||= (STREET_DIRECTIONS.keys + STREET_DIRECTIONS.values).freeze

  STREET_LABELS = {
    'avenue' => 'ave',
    'boulevard' => 'blvd',
    'boul' => 'blvd',
    'circle' => 'cir',
    'court' => 'ct',
    'drive' => 'dr',
    'expressway' => 'expy',
    'express' => 'expy',
    'expwy' => 'expy',
    'exwy' => 'expy',
    'highway' => 'hwy',
    'lane' => 'ln',
    'parkway' => 'pkwy',
    'place' => 'pl',
    'plaza' => 'plz',
    'road' => 'rd',
    'route' => 'rt',
    'square' => 'sq',
    'street' => 'st',
    'terrace' => 'tr',
    'trail' => 'trl',
    'way' => 'wy'
  }.freeze
  LABEL_DESCRIPTORS = (STREET_LABELS.keys + STREET_LABELS.values).freeze

  UNITS = {
    'no' => '#',
    'apartment' => 'apt',
    'suite' => 'ste',
    'room' => 'room',
    'unit' => '#',
    'p.o.box' => 'pobox',
    'po' => 'po',
    'box' => 'po'
  }.freeze
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
