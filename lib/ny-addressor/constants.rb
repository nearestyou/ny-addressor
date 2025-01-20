# frozen_string_literal: true
require 'set'
require 'byebug'

module NYAddressor
  module Constants
    module Generics
      STREET_NUMBERS = {
        '1st' => 'first',
        '2nd' => 'second',
        '3rd' => 'third',
        '4th' => 'fourth',
        '5th' => 'fifth',
        '6th' => 'sixth',
        '7th' => 'seventh',
        '8th' => 'eighth',
        '9th' => 'ninth',
        '10th' => 'tenth',
        '11th' => 'eleventh',
        '12th' => 'twelfth'
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
        'av' => 'ave',
        'boulevard' => 'blvd',
        'boul' => 'blvd',
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

      UNIT_DESIGNATIONS = {
        'no' => '#',
        'unit' => '#',
        'apartment' => 'apt',
        'suite' => 'ste',
        'room' => 'room',
        'pobox' => 'po',
        'box' => 'po',
        'rr' => 'po',
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
      :AU => "Australia",
      :CB => "Carribean Islands",
      :DE => "Germany"
    }.freeze

    STREET_NUMBERS = { }.freeze

    STREET_DIRECTIONS = { }.freeze

    STREET_LABELS = { }.freeze

    UNIT_DESIGNATIONS = { }.freeze

    STATES = {
      :DE => {},
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
      },
      :CB => {
        'saint maarten' => 'st maarten',
        'bermuda' => 'bermuda',
        'anguilla' => 'anguilla',
        'us virgin islands' => 'us virgin islands',
        'bahamas' => 'bahamas',
        'puerto rico' => 'pr',
        'caymand islands' => 'cayman islands',
        'montserrat' => 'montserrat',
        'british virgin islands' => 'british virgin islands',
        'trinidad' => 'trinidad',
        'tobago' => 'tobago',
        'saint vincent' => 'st vincent',
        'grenadines' => 'grenadines',
        'saint lucia' => 'st lucia',
        'saint kitts' => 'st kitts',
        'nevis' => 'nevis',
        'aruba' => 'aruba',
        'jamaica' => 'jamaica',
        'grenada' => 'grenada',
        'haiti' => 'haiti',
        'guadeloupe' => 'guadeloupe',
        'martinique' => 'martinique',
        'saint barthelemy' => 'st barthelemy',
        'barbados' => 'barbados',
        'antigua' => 'antigua'
      }
    }.freeze

    POSTAL_FORMATS = {
      # 12345 or 12345-6789
      US: /\b\d{5}(-\d{4})?\b/i,

      # A1B 2C3
      CA: /\b[A-Z]\d[A-Z]\s?\d[A-Z]\d\b/i,

      # SW1A 2BC
      UK: /\b[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}\b/i,

      # 2000
      AU: /\b\d{4}\b/i,

      # 52064
      DE: /\b\d{5}\b/i,
    }.freeze

    COUNTRY_IDENTIFIERS = {
      US: {
        "us" => "usa",
        "united states" => "usa",
        "united states of america" => "usa"
      },
      CA: { "canada" => "ca" },
      UK: { "united kingdom" => "uk" },
      AU: { "australia" => "au" },
      DE: { "germany" => "de" }
    }.freeze
  end
end
