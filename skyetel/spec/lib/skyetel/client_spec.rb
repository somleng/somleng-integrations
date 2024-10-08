require "spec_helper"

module Skyetel
  RSpec.describe Client do
    it "handles handles existing API tokens" do
      client = Client.new(api_token: APIToken.new(token: "api-token", retrieved_at: Time.now))

      stub_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/ratecenter",
        response_body: response_fixture(:ratecenter)
      )

      client.rate_centers(state: "NY")

      expect(
        a_request(:post, "https://apicontrol.call48.com/api/v4/admin_login")
      ).not_to have_been_made

      expect(
        a_request(
          :get, %r{https://apicontrol.call48.com/api/v4/ratecenter}
        ).with(headers: { "Authorization" => "api-token" })
      ).to have_been_made
    end

    it "handles expired API tokens" do
      client = Client.new(api_token: APIToken.new(token: "expired-token", retrieved_at: Time.now - (5 * 60)))

      stub_admin_login(token: "new-token")
      stub_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/ratecenter",
        response_body: [ response_fixture(:unauthorized_access), response_fixture(:ratecenter) ]
      )

      client.rate_centers(state: "NY")

      expect(
        a_request(
          :get, %r{https://apicontrol.call48.com/api/v4/ratecenter}
        ).with(headers: { "Authorization" => "expired-token" })
      ).to have_been_made

      expect(
        a_request(
          :get, %r{https://apicontrol.call48.com/api/v4/ratecenter}
        ).with(headers: { "Authorization" => "new-token" })
      ).to have_been_made
    end

    it "does not retry indefinitely" do
      client = Client.new(api_token: APIToken.new(token: "expired-token", retrieved_at: Time.now - (5 * 60)))

      stub_admin_login
      stub_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/ratecenter",
        response_body: response_fixture(:unauthorized_access)
      )

      expect { client.rate_centers(state: "NY") }.to raise_error(Errors::UnauthorizedError)
    end

    describe "#admin_login" do
      it "returns an API token" do
        client = Client.new(username: "skyeteluser", password: "password")
        stub_admin_login(token: "api-token")

        api_token = client.admin_login

        expect(api_token).to have_attributes(
          token: "api-token",
          retrieved_at: be_a(Time),
          expired?: false
        )

        expect(
          a_request(:post, "https://apicontrol.call48.com/api/v4/admin_login").with { |request|
            body = Rack::Utils.parse_query(request.body)
            expect(body).to eq(
              "user_name" => "skyeteluser",
              "password" => "password"
            )
            true
         }
        ).to have_been_made
      end

      it "handles incorrect credentials" do
        client = Client.new(username: "skyeteluser", password: "incorrect")

        stub_admin_login(response_fixture: response_fixture(:invalid_credentials))

        expect { client.admin_login }.to raise_error(Errors::ResponseError)
      end
    end

    describe "#rate_centers" do
      it "returns rate centers" do
        client = Client.new
        stub_admin_login(token: "api-token")
        stub_api_request(
          :get,
          "https://apicontrol.call48.com/api/v4/ratecenter",
          response_body: response_fixture(:ratecenter)
        )

        response = client.rate_centers(state: "NY")

        response.data.each do |data|
          expect(data).to have_attributes(
            footprint_id: be_a(Integer),
            rate_center: be_a(String),
          )
        end

        expect(
          a_request(
            :get, %r{https://apicontrol.call48.com/api/v4/ratecenter}
          ).with(query: { "state" => "NY" }, headers: { "Authorization" => "api-token" })
        ).to have_been_made
      end
    end

    describe "#states" do
      it "returns states" do
        client = Client.new
        stub_admin_login(token: "api-token")
        stub_api_request(
          :get,
          "https://apicontrol.call48.com/api/v4/states",
          response_body: response_fixture(:states)
        )

        response = client.states

        response.data.each do |data|
          expect(data).to have_attributes(
            state_id: be_a(Integer),
            state_name: be_a(String),
            state_code: be_a(String),
            country_id: be_a(Integer)
          )
        end

        expect(a_request(:get, "https://apicontrol.call48.com/api/v4/states")).to have_been_made
      end
    end

    describe "#search" do
      it "performs a search" do
        client = Client.new
        stub_admin_login(token: "api-token")
        stub_api_request(
          :get,
          "https://apicontrol.call48.com/api/v4/search",
          response_body: response_fixture(:search)
        )

        response = client.search(type: :local, state: "NY", rate_center: "NWYRCYZN01")

        response.data.each do |data|
          expect(data).to have_attributes(
            did_id: be_a(Integer),
            did_number: be_a(String),
            number: be_a(String),
            npa: be_a(String),
            nxx: be_a(String),
            xxxx: be_a(String),
            ratecenter: eq("NWYRCYZN01"),
            state: "NY",
            monthly: be_a(BigDecimal),
            setup: be_a(BigDecimal)
          )
        end

        expect(response.data.map(&:monthly)).to eq(
          [
            BigDecimal("0.02"),
            BigDecimal("0.02"),
            BigDecimal("0.15")
          ]
        )

        expect(
          a_request(
            :get, %r{https://apicontrol.call48.com/api/v4/search}
          ).with(
            query: {
              "state" => "NY",
              "ratecenter" => "NWYRCYZN01",
              "type" => "local",
              "limit" => "100"
            },
            headers: { "Authorization" => "api-token" }
          )
        ).to have_been_made
      end
    end

    def response_fixture(name)
      file_fixture("skyetel/responses/#{name}.json").read
    end

    def stub_admin_login(**options)
      response_body = JSON.parse(options.fetch(:response_fixture) { response_fixture(:admin_login) })
      response_body["data"]["token"] = options.fetch(:token) if options.key?(:token)
      response_body = response_body.to_json

      stub_api_request(
        :post,
        "https://apicontrol.call48.com/api/v4/admin_login",
        response_body:
      )
    end

    def stub_api_request(http_method, url, response_body: nil, response_headers: {})
      headers = { content_type: "application/json", **response_headers }
      response_bodies = Array(response_body).map { |body| { body:, headers:  } }
      stub_request(
        http_method, Regexp.new(url),
      ).to_return(*response_bodies)
    end
  end
end
