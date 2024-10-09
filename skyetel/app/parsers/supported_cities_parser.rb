require "csv"

class SupportedCitiesParser
  City = Struct.new(:country, :region, :name, :nearby_rate_centers, keyword_init: true)

  attr_reader :data

  def initialize(**options)
    @data = options.fetch(:data) { CSV.foreach(options.fetch(:data_file), headers: true) }
  end

  def parse
    load_cities
    load_skyetel_rate_centers

    RateCenter::City.all.map do |city|
      City.new(
        country: city.country,
        region: city.region,
        name: city.name,
        nearby_rate_centers: nearby_rate_centers_for(city)
      )
    end
  end

  private

  def load_cities
    filter = data.each_with_object(initialize_filter) do |row_data, result|
      result[row_data.fetch("country")][row_data.fetch("region")] << row_data.fetch("name")
    end

    RateCenter.data_loader.load(:cities, only: filter)
  end

  def nearby_rate_centers_for(city)
    nearby_rate_centers = city.nearby_rate_centers.select do |distance|
      Skyetel::RateCenter.find_by(country: city.country, state: city.region, name: distance.name)
    end

    raise Error::NoRateCenterFoundError("No nearby rate centers found for #{city.name}") if nearby_rate_centers.empty?

    nearby_rate_centers
  end

  def load_skyetel_rate_centers
    filter = RateCenter::City.all.each_with_object(initialize_filter) do |city, result|
      result[city.country][city.region].concat(city.nearby_rate_centers.map(&:name)).uniq
    end

    Skyetel.data_loader.load(:rate_centers, only: filter)
  end

  def initialize_filter
    Hash.new { |countries, country| countries[country] = Hash.new { |regions, region| regions[region] = [] } }
  end
end
