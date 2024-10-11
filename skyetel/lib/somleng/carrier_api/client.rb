require "jsonapi/client"

module Somleng
  module CarrierAPI
    class Client < JSONAPI::Client
      DEFAULT_BASE_URL = "carrier/v1".freeze

      def initialize(**options)
        super(
          host: options.fetch(:host) { Somleng.configuration.api_host },
          base_url: options.fetch(:base_url) { DEFAULT_BASE_URL },
          api_key: options.fetch(:api_key) { Somleng.configuration.carrier_api_key },
        )
      end

      def phone_number_stats(query)
        uri = URI("phone_numbers/stats")
        query = query.transform_keys(&:to_sym)
        pagination_options = query.fetch(:page, {})
        pagination_options[:size] ||= 100
        query[:page] = pagination_options
        uri.query = build_query(query)

        fetch(uri)
      end

      def create_phone_number(attributes)
        create_resource(url: "phone_numbers", type: :phone_number, attributes:)
      end

      private

      def build_query(...)
        Rack::Utils.build_nested_query(...)
      end
    end
  end
end
