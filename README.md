# NYAddressor
A Ruby gem for parsing, normalizing, and comparing address data. It supports various formats and ensures consistent output.

### Usage
```ruby
require `ny-addressor`
adr = NYAddressor.new('9000 Penn Ave N, Washington DC, 55555')
#<NYAddressor::Addressor(9000 Penn Ave N, Washington DC, 55555, US): 9000penndcwaaven55555
adr.to_s # "9000penndcwaaven55555"
adr.hash # "08ed8ddb49678e990b1a3c34"
adr.parts

adr2 = NYAddressor.new('9000 #2 Penn Ave W, Washington DC, 55555')
adr.compare(adr2) # 0.78
```


### Testing
```bash
rake test
ruby -Itest test/test_format_equality.rb --name test_unit_designations
```

### Deployment

1. Bump version in `ny-addressor.gemspec`
2. `gem build ny-addressor.gemspec`
