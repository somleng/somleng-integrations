require "spec_helper"

module App
  RSpec.describe Handler do
    it "restocks the Somleng inventory with Skyetel numbers" do
      stub_env(
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
      stub_app_settings(min_stock: 2, max_stock: 3, supplier: "skyetel")
      stub_jsonapi_request(
        :get, "https://api.somleng.org/carrier/v1/phone_numbers/stats",
        response_body: file_fixture("somleng/responses/phone_number_stats.json").read
      )
      stub_skyetel_admin_login
      stub_api_request(
        :get,
        "https://apicontrol.call48.com/api/v4/search",
        response_body: file_fixture("skyetel/responses/search.json").read
      )
      stub_api_request(
        :post,
        "https://apicontrol.call48.com/api/v4/purchase",
        response_body: file_fixture("skyetel/responses/purchase.json").read
      )
      stub_api_request(
        :post, "https://api.somleng.org/carrier/v1/phone_numbers",
        response_body: file_fixture("somleng/responses/create_phone_number.json").read
      )

      App::Handler.process(event: {}, context: double("LambdaContext", as_json: {}))

      expect(a_request(:post, "https://api.somleng.org/carrier/v1/phone_numbers")).to have_been_made.times(4)
    end
  end
end
