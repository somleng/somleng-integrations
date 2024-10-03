module JSONAPI
  class Parser
    def parse(raw_response, **options)
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
        raw_response.fetch("data").map { |data_entity| Data.new(**data_entity) },
        pagination:
      )

      Response.new(data:, pagination:)
    end
  end
end
