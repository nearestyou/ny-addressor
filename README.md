# NYAddressor
A Ruby gem for parsing, normalizing, and comparing address data. It supports various formats and ensures consistent output.

### Usage
```ruby
require `ny-addressor`
adr = NYAddressor.process('9000 Penn Ave N, Washington DC, 55555')
=> #<NYAddressor::Result:0x00007fc66216b180
adr.normalized
=> "9000 penn avenue n washington dc 55555"
adr.parts
=> 
{:house_number=>"9000",
 :street_name=>"penn",
 :street_label=>"avenue",
 :street_direction=>"n",
 :city=>"washington",
 :state=>"dc",
 :postcode=>"55555"}
adr.fingerprints
=> 
{:full=>"30fe69285ccd292151a642e15ecc78bb3379ff75bbed4441805bd9b19755af87",
 :zipless=>"3306761dba160109937ffd8a2cbd2c193647ed3b3722aab6cd4e91365ae0ed86",
 :unitless=>"30fe69285ccd292151a642e15ecc78bb3379ff75bbed4441805bd9b19755af87",
 :countryless=>"30fe69285ccd292151a642e15ecc78bb3379ff75bbed4441805bd9b19755af87",
 :sns=>"dcaded8625d8c4a80c6612239f2ce35249e1e895cd72032aed268a8fdc436e5b"}
```


### Testing
```bash
rake test
ruby -Itest test/test_format_equality.rb --name test_unit_designations
```

### Deployment

1. Bump version in `lib/ny-addressor/version.rb`
2. `gem build ny-addressor.gemspec`


### Docker

1. `docker compose up -d`
2. `docker exec -it ruby_libpostal bash`
