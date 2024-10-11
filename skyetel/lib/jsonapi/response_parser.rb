module JSONAPI
  class ResponseParser
    def parse(raw_response, **options)
      data = raw_response.fetch("data")
      return Response.new(data:) unless data.is_a?(Array)

      pagination = Pagination.new(
        prev: Page.new(
          client: options.fetch(:client),
          url: raw_response.dig("links", "prev")
        ),
        next: Page.new(
          client: options.fetch(:client),
          url: raw_response.dig("links", "next")
        )
      )

      data = DataCollection.new(
        data.map { |data_entity| Data.new(**data_entity) },
        pagination:
      )

      Response.new(data:, pagination:)
    end
  end
end
