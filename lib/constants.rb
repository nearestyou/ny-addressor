class NYAConstants

  CA_PROVINCES ||= {
    "Ontario" => "ON",
    "Quebec" => "QC",
    "Manitoba" => "MB",
    "Saskatchewan" => "SK",
    "Alberta" => "AB",
    "Yukon" => "YT",
    "Nunavut" => "NU",
  }

  CA_COMPOUND_PROVINCES ||= {
    "Nova Scotia" => "NS",
    "New Brunswick" => "NB",
    "British Columbia" => "BC",
    "Prince Edward Island" => "PE",
    "Newfoundland and Labrador" => "NL",
    "Northwest Territories" => "NT"
  }

  CA_DESCRIPTORS ||= (CA_PROVINCES.keys + CA_PROVINCES.values + CA_COMPOUND_PROVINCES.values).map(&:downcase)

  US_STATES ||= {
    "Alabama" => "AL",
    "Alaska" => "AK",
    "Arizona" => "AZ",
    "Arkansas" => "AR",
    "California" => "CA",
    "Colorado" => "CO",
    "Connecticut" => "CT",
    "Delaware" => "DE",
    # "District of Columbia" => "DC",
    "D.C." => "DC",
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
    "Ohio" => "OH",
    "Oklahoma" => "OK",
    "Oregon" => "OR",
    "Pennsylvania" => "PA",
    "Tennessee" => "TN",
    "Texas" => "TX",
    "Utah" => "UT",
    "Vermont" => "VT",
    "Virginia" => "VA",
    "Washington" => "WA",
    "Wisconsin" => "WI",
    "Wyoming" => "WY"
  }
  US_COMPOUND_STATES = {
    "District of Columbia" => 'DC',
    "New Hampshire" => "NH",
    "New Jersey" => "NJ",
    "New Mexico" => "NM",
    "New York" => "NY",
    "North Carolina" => "NC",
    "North Dakota" => "ND",
    "Puerto Rico" => "PR",
    "Rhode Island" => "RI",
    "South Carolina" => "SC",
    "South Dakota" => "SD",
    "West Virginia" => "WV"
  }

  other_descriptors = []
  # US_DESCRIPTORS ||= (US_STATES.keys + US_STATES.values + ['Columbia', 'Hampshire', 'Jersey', 'Mexico', 'York', 'Carolina', 'Dakota', 'Puerto', 'Rhode', 'Virginia'] + US_COMPOUND_STATES.values).map(&:downcase)
  US_DESCRIPTORS ||= (US_STATES.keys + US_STATES.values + US_COMPOUND_STATES.values).map(&:downcase)

  POBOX_ALIAS = [
    "po",
    "box",
    "pobox",
    "rr",
    "r.r."
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
  }
  LABEL_DESCRIPTORS ||= (STREET_LABELS.keys + STREET_LABELS.values)

  UNITS = {
    'no' => '#',
    'apartment' => 'apt',
    # 'suite' => 'ste',
    'room' => 'room',
    'unit' => '#'
  }
  UNIT_DESCRIPTORS ||= (UNITS.keys + UNITS.values)

  CA_SAINTS = ['st', 'saint', 'sainte'] #convert to ste

  CB_ISLANDS = ['st', 'maarten', 'bermuda', 'anguilla', 'bvis', 'virgin', 'islands', 'cayman', 'bahamas', 'trinidad', 'cotto', 'laurel', 'santa', 'isabel', 'british', 'devonshire']

end
