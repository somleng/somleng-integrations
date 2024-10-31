require "faraday"

module JSONAPI
  class Client
    attr_reader :host, :base_url, :api_key, :http_client, :response_parser

    def initialize(**options)
      @host = options.fetch(:host)
      @base_url = options.fetch(:base_url)
      @api_key = options.fetch(:api_key)
      @response_parser = options.fetch(:response_parser) { ResponseParser.new }
      @http_client = options.fetch(:http_client) { default_http_client }
    end

    def create_resource(url:, type:, attributes:)
      execute_request(:post, url, { data: { type:, attributes: } })
    end

    def fetch(url)
      execute_request(:get, url)
    end

    private

    def execute_request(http_method, url, params = nil, headers = {})
      response = http_client.run_request(http_method, url, params&.to_json, headers)
      response_parser.parse(response.body, client: self)
    end

    def default_http_client
      Faraday.new(url: "#{host}/#{base_url}") do |builder|
        builder.headers["Accept"] = "application/vnd.api+json"
        builder.headers["Content-Type"] = "application/vnd.api+json"

        builder.response :json
        builder.response :raise_error

        builder.request(:authorization, "Bearer", -> { api_key })
      end
    end
  end
end
