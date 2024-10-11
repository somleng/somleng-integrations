require "ostruct"
require_relative "collection"
require_relative "distance"

module RateCenter
  class RateCenter < OpenStruct
    extend Collection

    class << self
      private

      def data
        ::RateCenter.data_loader.rate_centers
      end

      def load_collection
        data.map do |data|
          rate_center = new(**data)
          closest_city = data["closest_city"]
          next rate_center if closest_city.nil?

          distance_km = closest_city.fetch("distance_km")
          rate_center.closest_city = Distance.new(
            name: closest_city.fetch("name"),
            distance_km:
          )

          rate_center
        end
      end
    end
  end
end
