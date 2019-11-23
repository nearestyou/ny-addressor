Gem::Specification.new do |s|
  s.name = "ny-addressor"
  s.version = "0.0.32"
  s.date = "2019-11-23"
  s.summary = 'An extension of StreetAddress that standardizes addresses for comparison to other addresses'
  s.author = 'P Kirwin'
  s.email = 'peter@puzzlesandwich.com'
  s.homepage = 'http://www.puzzlesandwich.com'
  s.files = [
    "lib/ny-addressor.rb"
  ]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'StreetAddress'
end
