require "spec_helper"

module Skyetel
  RSpec.describe Client do
    it "handles handles existing API tokens" do
      client = Client.new(api_token: APIToken.new(token: "api-token", retrieved_at: Time.now))

      stub_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/ratecenter",
        response_body: file_fixture("skyetel/responses/ratecenter.json").read
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

      stub_skyetel_admin_login(token: "new-token")
      stub_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/ratecenter",
        response_body: [
          file_fixture("skyetel/responses/unauthorized_access.json").read,
          file_fixture("skyetel/responses/ratecenter.json").read
        ]
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

      stub_skyetel_admin_login
      stub_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/ratecenter",
        response_body: file_fixture("skyetel/responses/unauthorized_access.json").read
      )

      expect { client.rate_centers(state: "NY") }.to raise_error(Errors::UnauthorizedError)
    end

    describe "#admin_login" do
      it "returns an API token" do
        client = Client.new(username: "skyeteluser", password: "password")
        stub_skyetel_admin_login(token: "api-token")

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

        stub_skyetel_admin_login(response_body: file_fixture("skyetel/responses/invalid_credentials.json").read)

        expect { client.admin_login }.to raise_error(Errors::ResponseError)
      end
    end

    describe "#rate_centers" do
      it "returns rate centers" do
        client = Client.new
        stub_skyetel_admin_login(token: "api-token")
        stub_api_request(
          :get,
          "https://apicontrol.call48.com/api/v4/ratecenter",
          response_body: file_fixture("skyetel/responses/ratecenter.json").read
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
        stub_skyetel_admin_login(token: "api-token")
        stub_api_request(
          :get,
          "https://apicontrol.call48.com/api/v4/states",
          response_body: file_fixture("skyetel/responses/states.json").read
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
        stub_skyetel_admin_login(token: "api-token")
        stub_api_request(
          :get,
          "https://apicontrol.call48.com/api/v4/search",
          response_body: file_fixture("skyetel/responses/search.json").read
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
            monthly: be_a(Float),
            setup: be_a(Float)
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

    describe "#purchase" do
      it "purchases numbers" do
        WebMock.allow_net_connect!
        client = Client.new
        stub_skyetel_admin_login(token: "api-token")
        stub_api_request(
          :post,
          "https://apicontrol.call48.com/api/v4/purchase",
          response_body: file_fixture("skyetel/responses/purchase.json").read
        )

        numbers = [
          OpenStruct.new(
            npa: "646",
            nxx: "631",
            xxxx: "6474",
            state: "NY",
            ratecenter: "NWYRCYZN01"
          )
        ]

        response = client.purchase(type: :local, numbers:)

        expect(response.data).to eq(true)
        expect(
          a_request(
            :post, "https://apicontrol.call48.com/api/v4/purchase"
          ).with(
            body:
              {
                type: "local",
                numbers: [
                  {
                    "npa" => "646",
                    "nxx" => "631",
                    "xxxx" => "6474",
                    "state" => "NY",
                    "ratecenter" => "NWYRCYZN01"
                  }
                ]
              }.to_json,
            headers: { "Authorization" => "api-token", "Content-Type" => "application/json" }
          )
        ).to have_been_made
      end
    end
  end
end
