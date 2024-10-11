require "yaml"
require "geocoder"

module RateCenter
  class DataPrep
    attr_reader :data_directory, :logger

    def initialize(**options)
      @data_directory = options.fetch(:data_directory)
    end

    def call
      update_rate_centers_with_closest_city
      update_cities_with_nearby_rate_centers
    end

    private

    def update_rate_centers_with_closest_city
      rate_center_data.each do |region, rate_centers|
        rate_centers.each do |rate_center|
          next if rate_center["lat"].nil? || rate_center["long"].nil?

          closest_city = find_closest(
            lat: rate_center.fetch("lat"),
            long: rate_center.fetch("long"),
            data: city_data[region],
            key: ->(data) { data.fetch("name") }
          ).first

          next if closest_city.nil?

          rate_center["closest_city"] = {
            "name" => closest_city.name,
            "distance_km" => closest_city.distance.round(2)
          }
        end
      end

      write_data("rate_centers", "us", rate_center_data)
    end

    def update_cities_with_nearby_rate_centers
      city_data.each do |region, cities|
        candidates = Array(rate_center_data[region]).reject { |data| data["lat"].nil? }

        cities.each do |city|
          candidate_distances = find_closest(
            lat: city.fetch("lat"),
            long: city.fetch("long"),
            data: candidates,
            key: ->(data) { data.fetch("name") }
          )

          candidates_by_distance = candidate_distances.each_with_object(Hash.new { |h, k| h[k] = [] }) do |rate_center, result|
            result[rate_center.distance] << rate_center
          end

          nearby_rate_centers = candidates_by_distance.keys.first(3).each_with_object([]) do |distance, result|
            result.concat(candidates_by_distance.fetch(distance))
          end

          city["nearby_rate_centers"] = nearby_rate_centers.map do |rate_center|
            {
              "name" => rate_center.name,
              "distance_km" => rate_center.distance.round(2)
            }
          end
        end
      end

      write_data("cities", "us", city_data)
    end

    def find_closest(lat:, long:, data:, key:)
      distance_to = Class.new(Struct.new(:name, :distance, keyword_init: true))

      distances_to = Array(data).map do |d|
        distance_to.new(
          name: key.call(d),
          distance: Geocoder::Calculations.distance_between(
            [ lat, long ],
            [ d.fetch("lat"), d.fetch("long") ],
            units: :km
          )
        )
      end

      distances_to.sort_by { |e| [ e.distance, e.name ] }
    end

    def write_data(type, country, data)
      data.each do |state, state_data|
        state_file = data_directory.join(type, country, "#{state.downcase}.yml")
        state_file.write({ type => state_data }.to_yaml)
      end
    end

    def city_data
      @city_data ||= load_data("cities", "us")
    end

    def rate_center_data
      @rate_center_data ||= load_data("rate_centers", "us")
    end

    def load_data(type, country)
      data_directory.join(type, country).glob("**/*.yml").each_with_object({}) do |state_file, result|
        data = YAML.load(state_file.read)
        state = state_file.basename(".yml").to_s
        result[state.upcase] = data.fetch(type.to_s)
      end
    end
  end
end
