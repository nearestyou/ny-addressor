class NYAConstants

  CA_PROVINCES ||= {
    "Ontario" => "ON",
    "Quebec" => "QC",
    "Nova Scotia" => "NS",
    "New Brunswick" => "NB",
    "Manitoba" => "MB",
    "British Columbia" => "BC",
    "Prince Edward Island" => "PE",
    "Saskatchewan" => "SK",
    "Alberta" => "AB",
    "Newfoundland and Labrador" => "NL",
    "Northwest Territories" => "NT",
    "Yukon" => "YT",
    "Nunavut" => "NU",
  }
  US_STATES ||= {
    "Alabama" => "AL",
    "Alaska" => "AK",
    "Arizona" => "AZ",
    "Arkansas" => "AR",
    "California" => "CA",
    "Colorado" => "CO",
    "Connecticut" => "CT",
    "Delaware" => "DE",
    "District of Columbia" => "DC",
    "Florida" => "FL",
    "Georgia" => "GA",
    "Hawaii" => "HI",
    "Idaho" => "ID",
    "Illinois" => "IL",
    "Indiana" => "IN",
    "Iowa" => "IA",
    "Kansas" => "KS",
    "Kentucky" => "KY",
    "Louisiana" => "LA",
    "Maine" => "ME",
    "Maryland" => "MD",
    "Massachusetts" => "MA",
    "Michigan" => "MI",
    "Minnesota" => "MN",
    "Mississippi" => "MS",
    "Missouri" => "MO",
    "Montana" => "MT",
    "Nebraska" => "NE",
    "Nevada" => "NV",
    "New Hampshire" => "NH",
    "New Jersey" => "NJ",
    "New Mexico" => "NM",
    "New York" => "NY",
    "North Carolina" => "NC",
    "North Dakota" => "ND",
    "Ohio" => "OH",
    "Oklahoma" => "OK",
    "Oregon" => "OR",
    "Pennsylvania" => "PA",
    "Puerto Rico" => "PR",
    "Rhode Island" => "RI",
    "South Carolina" => "SC",
    "South Dakota" => "SD",
    "Tennessee" => "TN",
    "Texas" => "TX",
    "Utah" => "UT",
    "Vermont" => "VT",
    "Virginia" => "VA",
    "Washington" => "WA",
    "West Virginia" => "WV",
    "Wisconsin" => "WI",
    "Wyoming" => "WY"
  }

  other_descriptors = []
  US_DESCRIPTORS ||= (US_STATES.keys + US_STATES.values).map(&:downcase)
  STATE_DESCRIPTORS ||= (US_STATES.keys + US_STATES.values + CA_PROVINCES.keys + CA_PROVINCES.values + other_descriptors).map(&:downcase)
  STATE_KEYS ||= (US_STATES.keys + CA_PROVINCES.keys).map(&:downcase)

  POBOX_ALIAS = [
    "po",
    "box",
    "pobox",
    "rr",
    "r.r."
  ]

  US_ALIAS = [
    'usa',
    'us',
    'united states of america',
    'united states'
  ]

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
  }

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
  }
  DIRECTION_DESCRIPTORS ||= (STREET_DIRECTIONS.keys + STREET_DIRECTIONS.values)

  STREET_LABELS = {
    'avenue' => 'ave',
    'boulevard' => 'blvd',
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
  }
  LABEL_DESCRIPTORS ||= (STREET_LABELS.keys + STREET_LABELS.values)

  UNITS = {
    'no' => '#',
    'apartment' => 'apt',
    'suite' => 'ste',
    'room' => 'room'
  }
  UNIT_DESCRIPTORS ||= (UNITS.keys + UNITS.values)

end
