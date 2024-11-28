require "faraday"
require "ostruct"
require "rack"
require_relative "response"
require_relative "response_parser"
require_relative "api_token"

module Skyetel
  class Client
    class SearchResponseParser
      def parse(raw_response)
        parsed_response = raw_response.dig("data", "result").map do |data|
          OpenStruct.new(
            **data,
            monthly: data.fetch("monthly").to_f,
            setup: data.fetch("setup").to_f
          )
        end

        Response.new(data: parsed_response.sort_by { |result| [ result.monthly, result.setup ] })
      end
    end


    DEFAULT_BASE_URL = "api/v4".freeze

    attr_reader :host, :base_url, :username, :password, :api_token, :http_client, :response_parser

    def initialize(**options)
      @host = options.fetch(:host) { Skyetel.configuration.api_host }
      @base_url = options.fetch(:base_url, DEFAULT_BASE_URL)
      @username = options.fetch(:username) { Skyetel.configuration.username }
      @password = options.fetch(:password) { Skyetel.configuration.password }
      @response_parser = options.fetch(:response_parser) { ResponseParser.new }
      @api_token = options[:api_token]
      @http_client = options.fetch(:http_client) { default_http_client }
    end

    def rate_centers(state:)
      uri = URI("ratecenter")
      uri.query = Rack::Utils.build_query(state:)

      response = execute_request(:get, uri)
      Response.new(data: Array(response["data"]).map { |data| OpenStruct.new(**data) })
    end

    def states
      response = execute_request(:get, "states")
      Response.new(data: response.fetch("data").map { |data| OpenStruct.new(**data) })
    end

    def search(params)
      uri = URI("search")
      params = {
        state: params.fetch(:state),
        ratecenter: params.fetch(:rate_center),
        type: params.fetch(:type)
      }

      params[:limit] = params.fetch(:limit, 100)
      params[:npa] = params.fetch(:npa) if params.key?(:npa)
      params[:npx] = params.fetch(:npx) if params.key?(:npx)
      uri.query = Rack::Utils.build_query(**params)

      raw_response = execute_request(:get, uri)
      SearchResponseParser.new.parse(raw_response)
    end

    def purchase(type:, numbers:)
      numbers = Array(numbers).map do |number|
        {
          npa: number.npa,
          nxx: number.nxx,
          xxxx: number.xxxx,
          state: number.state,
          ratecenter: number.ratecenter
        }
      end

      response = execute_request(
        :post,
        URI("purchase"),
        params: { type:, numbers: }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
      Response.new(data: response.fetch("data"))
    end

    def admin_login
      params = { user_name: username, password: }

      response = execute_request(:post, URI("admin_login"), params:, retry: false, authorization: false)
      @api_token = APIToken.new(
        token: response.dig("data", "token"),
        retrieved_at: Time.now
      )
    end

    private

    def execute_request(http_method, url, **options)
      headers = options.fetch(:headers, {})
      headers["Authorization"] ||= (api_token || admin_login).token unless options[:authorization] == false
      response = http_client.run_request(http_method, url, options[:params], headers)
      response_parser.parse(response.body, client: self)
    rescue Errors::UnauthorizedError
      if options.fetch(:retry, true) != false && api_token&.expired?
        admin_login
        retry
      else
        raise
      end
    rescue Faraday::TimeoutError => e
      raise Errors::TimeoutError.new(e.message)
    end

    def default_http_client
      Faraday.new(url: "#{host}/#{base_url}") do |builder|
        builder.options.timeout = 10
        builder.request :url_encoded
        builder.response :json
        builder.response :raise_error
      end
    end
  end
end
