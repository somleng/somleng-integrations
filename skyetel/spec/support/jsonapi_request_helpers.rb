module JSONAPIRequestHelpers
  def stub_jsonapi_request(http_method, url, response_body: nil, response_headers: {})
    stub_request(http_method, Regexp.new(url)).to_return do |request|
      {
        body: json_response_body(response_body, request:),
        headers: { content_type: "application/vnd.api+json", **response_headers }
      }
    end
  end

  def json_response_body(body, request:)
    return if body.nil?

    request_uri = URI(request.uri.to_s)
    response_body = JSON.parse(body)
    response_data = response_body.fetch("data")
    paginated_response_data = paginate_response(request:, response_body:)

    response_body["links"] = {
      "prev" => build_page_uri_from(
        request_uri,
        cursor_options: { "before" => paginated_response_data.first.fetch("id") },
        paginated_response_data:,
        reference_id: response_data.first.fetch("id")
      ),
      "next" => build_page_uri_from(
        request_uri,
        cursor_options: { "after" => paginated_response_data.last.fetch("id") },
        paginated_response_data:,
        reference_id: response_data.last.fetch("id")
      )
    }
    response_body["data"] = paginated_response_data
    response_body.to_json
  end

  def paginate_response(request:, response_body:)
    request_query = Rack::Utils.parse_nested_query(request.uri.query)
    response_data = response_body.fetch("data")
    page_size = request_query.dig("page", "size")&.to_i
    response_ids = response_data.map { |data| data.fetch("id") }

    if (after_cursor = request_query.dig("page", "after"))
      data = response_data[(response_ids.find_index(after_cursor) + 1)..]
      data = data.first(page_size) if page_size
      data
    elsif (before_cursor = request_query.dig("page", "before"))
      data = response_data[..(response_ids.find_index(before_cursor))].last(page_size)
      data = data.last(page_size) if page_size
      data
    else
      page_size.nil? ? response_data : response_data.first(page_size)
    end
  end

  def build_page_uri_from(uri, cursor_options:, paginated_response_data:, reference_id:)
    return if paginated_response_data.map { |data| data.fetch("id") }.include?(reference_id)

    request_query = Rack::Utils.parse_nested_query(uri.query)
    pagination_options = request_query.fetch("page", {}).slice("size", *cursor_options.keys)

    page_uri = uri.dup
    page_uri.query = Rack::Utils.build_nested_query(
      request_query.merge("page" => pagination_options.merge(cursor_options))
    )

    page_uri
  end
end

RSpec.configure do |config|
  config.include(JSONAPIRequestHelpers)
end
