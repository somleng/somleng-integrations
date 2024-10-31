require "faraday"
require "ostruct"
require "rack"
require_relative "response"
require_relative "response_parser"

module Fibernetics
  class Client
    DEFAULT_BASE_URL = "api".freeze

    attr_reader :host, :base_url, :api_token, :http_client, :response_parser

    def initialize(**options)
      @host = options.fetch(:host) { Fibernetics.configuration.api_host }
      @base_url = options.fetch(:base_url, DEFAULT_BASE_URL)
      @api_token = options.fetch(:api_token) { Fibernetics.configuration.api_token }
      @response_parser = options.fetch(:response_parser) { ResponseParser.new }
      @http_client = options.fetch(:http_client) { default_http_client }
    end

    def available_npa_nxx(params = {})
      uri = URI("did-management/available-npa-nxx")
      uri.query = Rack::Utils.build_query(params)

      response = execute_request(:get, uri)
      Response.new(data: Array(response["results"]).map { |data| OpenStruct.new(**data, rc: data.fetch("rc").strip.upcase) })
    end

    def available_tns(params = {})
      uri = URI("did-management/available-tns")
      uri.query = Rack::Utils.build_query(params)

      response = execute_request(:get, uri)
      Response.new(data: Array(response["results"]))
    end

    private

    def execute_request(http_method, url, **options)
      headers = options.fetch(:headers, {})
      headers["X-Wapig-Api-Token"] ||= api_token
      response = http_client.run_request(http_method, url, options[:params], headers)
      response_parser.parse(response.body)
    end

    def default_http_client
      Faraday.new(url: "#{host}/#{base_url}") do |builder|
        builder.request :url_encoded
        builder.response :json
        builder.response :raise_error
      end
    end
  end
end
