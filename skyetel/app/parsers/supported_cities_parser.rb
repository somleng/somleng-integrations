require "csv"

class SupportedCitiesParser
  City = Struct.new(:country, :region, :name, :nearby_rate_centers, keyword_init: true)

  attr_reader :data_file

  def initialize(**options)
    @data_file = options.fetch(:data_file)
  end

  def parse
    filter_data = Hash.new { |countries, country| countries[country] = Hash.new { |regions, region| regions[region] = [] } }

    filter = CSV.foreach(data_file, headers: true).each_with_object(filter_data) do |row_data, result|
      result[row_data.fetch("country")][row_data.fetch("region")] << row_data.fetch("name")
    end

    RateCenter.data_loader.load(:cities, only: filter)

    RateCenter::City.all.map do |city|
      City.new(
        country: city.country,
        region: city.region,
        name: city.name,
        nearby_rate_centers: city.nearby_rate_centers
      )
    end
  end
end
