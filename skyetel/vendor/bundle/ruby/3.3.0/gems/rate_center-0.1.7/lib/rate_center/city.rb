
require "ostruct"
require_relative "collection"
require_relative "distance"

module RateCenter
  class City < OpenStruct
    extend Collection

    class << self
      private

      def data
        ::RateCenter.data_loader.cities
      end

      def load_collection
        data.map do |data|
          city = new(**data)
          city.nearby_rate_centers = Array(data["nearby_rate_centers"]).map do |rate_center|
            distance_km = rate_center.fetch("distance_km")
            Distance.new(
              name: rate_center.fetch("name"),
              distance_km:
            )
          end
          city
        end
      end
    end
  end
end
