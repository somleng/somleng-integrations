# RateCenter

[![Build](https://github.com/somleng/rate_center/actions/workflows/main.yml/badge.svg)](https://github.com/somleng/rate_center/actions/workflows/main.yml)

A collection of useful data about [NANPA Rate Centers](https://en.wikipedia.org/wiki/Rate_center).

Data is currently sourced from [Simple Maps](https://simplemaps.com/data/us-cities) and [Local Calling Guide](https://localcallingguide.com/).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add rate_centers
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install rate_centers
```

## Usage

### Working with Rate Centers

```rb
# Load rate centers
RateCenter.load(:rate_centers, only: { us: [:ny, :ca] }) # Loads rate centers in New York and California
# RateCenter.load(:rate_centers, only: { us: { ny: [ "NWYRCYZN01" ], ca: [ "LSAN DA 01"]  } }) # Loads only specific rate centers
# RateCenter.load(:rate_centers, only: { [ :us ] }) # Load all rate centers in US
# RateCenter.load(:rate_centers, :all) # Load all rate centers

# RateCenter::RateCenter.all # returns all rate centers loaded

rate_center = RateCenter::RateCenter.find_by!(country: "US", region: "NY", name: "NWYRCYZN01")
rate_center.full_name # "New York City Zone 01"
rate_center.lata # 132
rate_center.ilec_name # "VERIZON NEW YORK, INC."
rate_center.lat # "40.739362"
rate_center.long # "-73.991043"
rate_center.closest_city.name # "Manhattan"
rate_center.closest_city.distance_km # 5.33
```

### Working with Cities

```rb
# Load cities
RateCenter.load(:cities, only: { us: [:ny, :ca] }) # Loads cities in New York and California
# RateCenter.load(:cities, only: { us: { ny: [ "New York" ], ca: [ "Los Angeles"]  } }) # Loads only specific cities
# RateCenter.load(:cities, only: { [ :us ] }) # Load all cities in US
# RateCenter.load(:cities, :all) # Load all cities

# RateCenter::City.all # returns all cities loaded

city = RateCenter::City.find_by!(country: "US", region: "NY", name: "New York")
city.lat # "40.6943"
city.log # "-73.9249"
city.nearby_rate_centers.each do |rate_center|
  puts "Rate Center: #{rate_center.name}, Distance: #{rate_center.distance_km} km"
end
# Rate Center: NWYRCYZN01, Distance: 7.5 km
# Rate Center: NWYRCYZN03, Distance: 7.5 km
# Rate Center: NWYRCYZN04, Distance: 7.5 km
# Rate Center: NWYRCYZN05, Distance: 7.5 km
# Rate Center: NWYRCYZN06, Distance: 7.5 km
# Rate Center: NWYRCYZN07, Distance: 7.5 km
# Rate Center: NWYRCYZN08, Distance: 7.5 km
# Rate Center: NWYRCYZN09, Distance: 7.5 km
# Rate Center: NWYRCYZN10, Distance: 7.5 km
# Rate Center: NWYRCYZN11, Distance: 7.5 km
# Rate Center: NWYRCYZN12, Distance: 7.5 km
# Rate Center: NWYRCYZN13, Distance: 7.5 km
# Rate Center: NWYRCYZN14, Distance: 7.5 km
# Rate Center: NWYRCYZN15, Distance: 7.5 km
# Rate Center: NASSAUZN02, Distance: 18.96 km
# Rate Center: NASSAUZN03, Distance: 20.16 km
```

## Updating Data

In order to pull data from the sources, run the following script

```bash
bin/update_data
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/somleng/rate_center.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
