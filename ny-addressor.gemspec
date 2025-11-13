require_relative "lib/ny-addressor/version"
Gem::Specification.new do |s|
  s.name = 'ny-addressor'
  s.version = NYAddressor::VERSION
  s.summary = 'Address parsing/normalization with libpostal'
  s.authors = ['P Kirwin', 'C Hanson']
  s.email = 'peter@puzzlesandwich.com'
  s.homepage = 'http://www.puzzlesandwich.com'
  s.files = Dir["lib/**/*.rb"] + ["README.md"]
  s.add_dependency "ruby_postal", "~> 1.0.1"
  s.add_dependency "countries", "~> 5.7"

  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "byebug"
  s.add_development_dependency "rake"
end
