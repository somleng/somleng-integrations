require "json"

module Skyetel
  module DataSource
    class RateCenters
      attr_reader :client

      def initialize(**options)
        @client = options.fetch(:client) { Skyetel::Client.new }
      end

      def load_data!(**options)
        data_directory = options.fetch(:data_directory)
        FileUtils.mkdir_p(data_directory)

        Array(states).each do |state|
          state_code = state.state_code
          data_file = data_directory.join("#{state_code.downcase}.json")

          rate_centers = rate_centers_for(state_code).data.sort_by { |rc| [ rc.name, rc.footprint_id ] }.map do |rate_center|
            {
              "country" => "US",
              "state" => state_code.upcase,
              "name" => rate_center.rate_center,
              "footprint_id" => rate_center.footprint_id
            }
          end

          data_file.write(JSON.pretty_generate("rate_centers" => rate_centers)) unless rate_centers.empty?
        end
      end

      private

      def states
        @states ||= client.states.data
      end

      def rate_centers_for(state)
        client.rate_centers(state:)
      end
    end
  end
end
