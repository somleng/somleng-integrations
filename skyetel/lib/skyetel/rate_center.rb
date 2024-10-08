require "ostruct"

module Skyetel
  class RateCenter < OpenStruct
    class << self
      def collection
        raise Errors::DataNotLoadedError.new("No data loaded. Load data with RateCenter.load before calling this method") if data.nil?

        @collection ||= load_collection
      end

      def all
        collection
      end

      def find_by(attributes)
        collection.find do |rate_center|
          attributes.all? { |key, value| rate_center[key] == value }
        end
      end

      def find_by!(*)
        find_by(*) || raise(Errors::NotFoundError.new)
      end

      private

      def data
        ::Skyetel.data_loader.rate_centers
      end

      def load_collection
        data.map { |data| new(**data) }
      end
    end
  end
end
