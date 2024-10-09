require "spec_helper"

module App
  RSpec.describe Handler do
    it "does something" do
      stub_env(
        "MAX_STOCK" => 2,
        "SUPPORTED_CITIES" => [
          {
            "country" => "US",
            "region" => "NY",
            "name" => "New York"
          },
          {
            "country" => "US",
            "region" => "CA",
            "name" => "Los Angeles"
          }
        ].to_json
      )

      stub_jsonapi_request(
        :get, "https://api.somleng.org/carrier/v1/phone_numbers/stats",
        response_body: file_fixture("somleng/carrier_api/responses/phone_number_stats.json").read
      )
      stub_skyetel_admin_login
      stub_skyetel_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/search",
        response_body: file_fixture("skyetel/responses/search.json").read
      )
      stub_skyetel_api_request(
        :post,
        "https://apicontrol.call48.com/api/v4/purchase",
        response_body: file_fixture("skyetel/responses/purchase.json").read
      )
      stub_jsonapi_request(
        :post, "https://api.somleng.org/carrier/v1/phone_numbers",
        response_body: file_fixture("somleng/carrier_api/responses/create_phone_number.json").read
      )

      handler = build_handler
      handler.process

      expect(
        a_request(:post, "https://api.somleng.org/carrier/v1/phone_numbers").with(body: "foo")
      ).to have_been_made
    end

    def build_handler(**options)
      Handler.new(event: {}, context: double("LambdaContext", as_json: {}), **options)
    end
  end
end
