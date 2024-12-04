# frozen_string_literal: true

module NYAddressor
  module Constants
    module Generics
      STREET_NUMBERS = {
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

      STREET_LABELS = {
        'avenue' => 'ave',
        'av.' => 'ave',
        'boulevard' => 'blvd',
        'boul' => 'blvd',
        'boul.' => 'blvd',
        'circle' => 'cir',
        'court' => 'ct',
        'drive' => 'dr',
        'expressway' => 'expy',
        'express' => 'expy',
        'expwy' => 'expy',
        'exwy' => 'expy',
        'expy wy' => 'expy',
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

      UNIT_TYPES = {
        'no' => '#',
        'apartment' => 'apt',
        'suite' => 'ste',
        'room' => 'room',
        'unit' => '#',
        'p.o.box' => 'po',
        'pobox' => 'po',
        'box' => 'po',
        'rr' => 'po',
        'r.r.' => 'po'
      }.freeze
    end # end generics
  end
end


module NYAddressor
  module Constants
    COUNTRIES = {
      :US => "United States",
      :CA => "Canada",
      :UK => "United Kingdom",
      :AU => "Australia"
    }.freeze

    STREET_NUMBERS = { }.freeze

    STREET_DIRECTIONS = { }.freeze

    STREET_LABELS = { }.freeze

    UNIT_TYPES = { }.freeze

    STATES = {
      :US => {
        'alabama' => 'al',
        'alaska' => 'ak',
        'arizona' => 'az',
        'arkansas' => 'ar',
        'california' => 'ca',
        'colorado' => 'co',
        'connecticut' => 'ct',
        'delaware' => 'de',
        'district of columbia' => 'dc',
        'd.c.' => 'dc',
        'florida' => 'fl',
        'georgia' => 'ga',
        'hawaii' => 'hi',
        'idaho' => 'id',
        'illinois' => 'il',
        'indiana' => 'in',
        'iowa' => 'ia',
        'kansas' => 'ks',
        'kentucky' => 'ky',
        'louisiana' => 'la',
        'maine' => 'me',
        'maryland' => 'md',
        'massachusetts' => 'ma',
        'michigan' => 'mi',
        'minnesota' => 'mn',
        'mississippi' => 'ms',
        'missouri' => 'mo',
        'montana' => 'mt',
        'nebraska' => 'ne',
        'nevada' => 'nv',
        'new hampshire' => 'nh',
        'new jersey' => 'nj',
        'new mexico' => 'nm',
        'new york' => 'ny',
        'north carolina' => 'nc',
        'north dakota' => 'nd',
        'ohio' => 'oh',
        'oklahoma' => 'ok',
        'oregon' => 'or',
        'pennsylvania' => 'pa',
        'puerto rico' => 'pr',
        'rhode island' => 'ri',
        'south carolina' => 'sc',
        'south dakota' => 'sd',
        'tennessee' => 'tn',
        'texas' => 'tx',
        'utah' => 'ut',
        'vermont' => 'vt',
        'virginia' => 'va',
        'washington' => 'wa',
        'west virginia' => 'wv',
        'wisconsin' => 'wi',
        'wyoming' => 'wy'
      },
      :CA => {
        'ontario' => 'on',
        'quebec' => 'qc',
        'nova scotia' => 'ns',
        'new brunswick' => 'nb',
        'manitoba' => 'mb',
        'british columbia' => 'bc',
        'prince edward island' => 'pe',
        'saskatchewan' => 'sk',
        'alberta' => 'ab',
        'newfoundland and labrador' => 'nl',
        'northwest territories' => 'nt',
        'yukon' => 'yt',
        'nunavut' => 'nu'
      },
      :UK => {
        'eng' => 'england',
        'en' => 'england',
        'wls' => 'wales',
        'wal' => 'wales',
        'ws' => 'wales',
        'scotland' => 'sct',
        'ireland' => 'ir',
        'northern ireland' => 'nir'
      },
      :AU => {
        'new south wales' => 'nsw',
        'victoria' => 'vic',
        'queensland' => 'qld',
        'western australia' => 'wa',
        'south australia' => 'sa',
        'tasmania' => 'tas'
      }
    }.freeze

    POSTAL_FORMATS = {
      US: /\d{5}(-\d{4})?/i,                       # 12345 or 12345-6789
      CA: /[A-Z]\d[A-Z] \d[A-Z]\d/i,               # A1B 2C3
      UK: /[A-Z]{1,2}\d[A-Z\d]? \d[A-Z]{2}/i,      # SW1A 1AA
      AU: /\d{4}/i                                 # 2000
    }.freeze
  end
end
