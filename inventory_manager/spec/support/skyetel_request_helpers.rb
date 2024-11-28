require_relative "request_helpers"

module SkyetelRequestHelpers
  def stub_skyetel_admin_login(**options)
    response_body = JSON.parse(options.fetch(:response_body) { file_fixture("skyetel/responses/admin_login.json").read })
    response_body["data"]["token"] = options.fetch(:token) if options.key?(:token)
    response_body = response_body.to_json

    stub_api_request(
      :post,
      "https://apicontrol.call48.com/api/v4/admin_login",
      response_body:
    )
  end
end

RSpec.configure do |config|
  config.include(SkyetelRequestHelpers)
end
