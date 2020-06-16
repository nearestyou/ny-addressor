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
  STATE_DESCRIPTORS ||= (US_STATES.keys + US_STATES.values + CA_PROVINCES.keys + CA_PROVINCES.values + other_descriptors).map(&:downcase)

  POBOX_ALIAS = [
    "po",
    "box",
    "pobox",
    "rr",
    "r.r."
  ]

end
