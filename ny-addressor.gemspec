Gem::Specification.new do |s|
  s.name = "ny-addressor"
  s.version = "0.0.14"
  s.date = "2019-04-08"
  s.summary = 'An extension of StreetAddress that standardizes addresses for comparison to other addresses'
  s.author = 'P Kirwin'
  s.files = [
    "lib/ny-addressor.rb"
  ]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'StreetAddress'
end
