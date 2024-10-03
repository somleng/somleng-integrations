module JSONAPI
  class Parser
    def parse(raw_response, **options)
      data = DataCollection.new(
        raw_response.fetch("data").map { |data_entity| Data.new(**data_entity) },
        pagination: Pagination.new(
          prev: Page.new(
            client: options.fetch(:client),
            url: raw_response.dig("links", "prev")
          ),
          next: Page.new(
            client: options.fetch(:client),
            url: raw_response.dig("links", "next")
          )
        )
      )

      Response.new(data:)
    end
  end
end
