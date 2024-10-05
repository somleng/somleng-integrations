require "spec_helper"

module Skyetel
  RSpec.describe Client do
    describe "#rate_centers" do
      it "returns rate centers" do
        client = Client.new(username: "skyeteluser", password: "password")

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
          a_request(:post, "https://apicontrol.call48.com/api/v4/admin_login").with { |request|
            body = Rack::Utils.parse_query(request.body)
            expect(body).to eq(
              "user_name" => "skyeteluser",
              "password" => "password"
            )
            true
         }
        ).to have_been_made

        expect(
          a_request(
            :get, %r{https://apicontrol.call48.com/api/v4/ratecenter}
          ).with(query: { "state" => "NY" }, headers: { "Authorization" => "api-token" })
        ).to have_been_made
      end
    end

    def response_fixture(name)
      file_fixture("skyetel/responses/#{name}.json").read
    end

    def stub_admin_login(**options)
      response_body = JSON.parse(response_fixture(:admin_login))
      response_body["data"]["token"] = options.fetch(:token) if options.key?(:token)
      response_body = response_body.to_json

      stub_api_request(
        :post,
        "https://apicontrol.call48.com/api/v4/admin_login",
        response_body:
      )
    end

    def stub_api_request(http_method, url, response_body: nil, response_headers: {})
      stub_request(
        http_method, Regexp.new(url),
      ).to_return(
        body: response_body,
        headers: { content_type: "application/json", **response_headers }
      )
    end
  end
end
