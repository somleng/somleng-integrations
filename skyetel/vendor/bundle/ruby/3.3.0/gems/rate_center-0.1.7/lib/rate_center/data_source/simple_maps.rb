require "faraday"
require "zip"
require "csv"
require "yaml"
require "ostruct"

module RateCenter
  module DataSource
    class SimpleMaps
      class ResponseParser
        DATABASE_FILENAME = "uscities.csv".freeze

        def parse(response)
          database_file = extract_zipped_file(response, filename: DATABASE_FILENAME)

          CSV.parse(database_file.read, headers: true).each_with_object([]) do |row_data, result|
            result << OpenStruct.new(row_data.to_h)
          end
        end

        private

        def extract_zipped_file(zip_data, filename:)
          Zip::InputStream.open(StringIO.new(zip_data)) do |zip_stream|
            while (entry = zip_stream.get_next_entry)
              return entry.get_input_stream if entry.name == filename
            end
          end
        end
      end

      class Client
        HOST = "https://simplemaps.com/".freeze
        DEFAULT_DOWNLOAD_PATH = "static/data/us-cities/1.79/basic/simplemaps_uscities_basicv1.79.zip"

        attr_reader :host, :http_client, :response_parser

        def initialize(**options)
          @host = options.fetch(:host, HOST)
          @http_client = options.fetch(:http_client) { default_http_client }
          @response_parser =  options.fetch(:response_parser) { ResponseParser.new }
        end

        def fetch_data(**options)
          uri = URI(options.fetch(:path, DEFAULT_DOWNLOAD_PATH))
          response = http_client.get(uri)
          response_parser.parse(response.body)
        end

        private

        def default_http_client
          Faraday.new(url: host) do |builder|
            builder.response :raise_error
          end
        end
      end

      attr_reader :client, :data_directory

      def initialize(**options)
        @client = options.fetch(:client) { Client.new }
      end

      def load_data!(**options)
        data_directory = options.fetch(:data_directory)
        FileUtils.mkdir_p(data_directory)

        data = client.fetch_data

        cities_by_state = data.each_with_object(Hash.new { |h, k| h[k] = [] }) do |city, result|
          result[city.state_id] << city
        end

        cities_by_state.each do |state, cities|
          data_file = data_directory.join("#{state.downcase}.yml")

          data = cities.sort_by(&:city).map do |city|
            {
              "country" => "US",
              "region" => city.state_id,
              "name" => city.city,
              "lat" => city.lat,
              "long" => city.lng
            }
          end

          data_file.write({ "cities" => data }.to_yaml)
        end
      end
    end
  end
end
