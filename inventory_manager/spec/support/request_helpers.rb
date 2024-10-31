module RequestHelpers
  def stub_api_request(http_method, url, response_body: nil, response_headers: {})
    headers = { content_type: "application/json", **response_headers }
    response_bodies = Array(response_body).map { |body| { body:, headers:  } }
    stub_request(http_method, Regexp.new(url)).to_return(*response_bodies)
  end
end

RSpec.configure do |config|
  config.include(RequestHelpers)
end
