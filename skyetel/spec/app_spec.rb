require "spec_helper"

module App
  RSpec.describe Handler do
    it "restocks the Somleng inventory with Skyetel numbers" do
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
        response_body: file_fixture("somleng/responses/phone_number_stats.json").read
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
        response_body: file_fixture("somleng/responses/create_phone_number.json").read
      )

      App::Handler.process(event: {}, context: double("LambdaContext", as_json: {}))

      expect(a_request(:post, "https://api.somleng.org/carrier/v1/phone_numbers")).to have_been_made.times(2)
    end
  end
end
