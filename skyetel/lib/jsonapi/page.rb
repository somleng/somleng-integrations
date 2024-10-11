module JSONAPI
  class Page
    attr_reader :url, :client

    def initialize(**options)
      @url = options.fetch(:url)
      @client = options.fetch(:client)
    end

    def fetch
      return Response.new(data: DataCollection.new([])) if url.nil?

      client.fetch(url)
    end
  end
end
