module Supplier
  class Fibernetics
    attr_reader :client

    def initialize(**options)
      @client = options.fetch(:client) { ::Fibernetics::Client.new }
    end

    def find_stock_for(shopping_list_line_item)

    end
  end
end
