Gem::Specification.new do |s|
  s.name = "NearestYou-Addressor"
  s.version = "0.0.1"
  s.date = "2018-11-09"
  s.summary = 'An extension of StreetAddress that standardizes addresses for comparison to other addresses'
  s.files = [
    "lib/addressor.rb"
  ]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'StreetAddress'
end
