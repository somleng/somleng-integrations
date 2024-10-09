module SkyetelRequestHelpers
  def stub_skyetel_admin_login(**options)
    response_body = JSON.parse(options.fetch(:response_fixture) { file_fixture("skyetel/responses/admin_login.json").read })
    response_body["data"]["token"] = options.fetch(:token) if options.key?(:token)
    response_body = response_body.to_json

    stub_skyetel_api_request(
      :post,
      "https://apicontrol.call48.com/api/v4/admin_login",
      response_body:
    )
  end

  def stub_skyetel_api_request(http_method, url, response_body: nil, response_headers: {})
    headers = { content_type: "application/json", **response_headers }
    response_bodies = Array(response_body).map { |body| { body:, headers:  } }
    stub_request(http_method, Regexp.new(url)).to_return(*response_bodies)
  end
end

RSpec.configure do |config|
  config.include(SkyetelRequestHelpers)
end
