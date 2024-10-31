module Supplier
  class Skyetel
    class NoRateCenterFoundError < StandardError; end

    attr_reader :client, :cities

    def initialize(**options)
      @client = options.fetch(:client) { ::Skyetel::Client.new }
      @cities = options.fetch(:cities) { AppSettings.supported_cities }
      load_skyetel_rate_centers
    end

    def generate_purchase_order(shopping_list)
      line_items = shopping_list.line_items.map do |shopping_list_line_item|
        numbers = nearby_rate_centers_for(shopping_list_line_item.city).each_with_object([]) do |rate_center, dids|
          dids.concat(search_dids(shopping_list_line_item:, rate_center:))
          dids.size < shopping_list_line_item.quantity ? next : (break dids)
        end

        PurchaseOrder::LineItem.new(
          city: shopping_list_line_item.city,
          numbers: numbers.first(shopping_list_line_item.quantity)
        )
      end

      PurchaseOrder.new(line_items:)
    end

    def execute_order(purchase_order)
      client.purchase(type: :local, numbers: purchase_order.to_order)
    end

    private

    def load_skyetel_rate_centers
      filter = cities.each_with_object(initialize_filter) do |city, result|
        result[city.country][city.region].concat(city.nearby_rate_centers.map(&:name))
      end

      ::Skyetel.data_loader.load(:rate_centers, only: filter)
      ::Skyetel::RateCenter.reload!
    end

    def nearby_rate_centers_for(city)
      nearby_rate_centers = city.nearby_rate_centers.each_with_object([]) do |distance, result|
        skyetel_rate_center = ::Skyetel::RateCenter.find_by(country: city.country, state: city.region, name: distance.name)
        result << RateCenter::RateCenter.find_by(country: city.country, region: city.region, name: distance.name) if skyetel_rate_center
      end

      raise NoRateCenterFoundError.new("No nearby rate centers found for #{city.name}") if nearby_rate_centers.empty?

      nearby_rate_centers
    end

    def search_dids(shopping_list_line_item:, rate_center:)
      results = client.search(
        type: :local,
        state: shopping_list_line_item.city.region,
        rate_center: rate_center.name,
        limit: shopping_list_line_item.quantity
      )

      results.data.map { |result| PurchaseOrder::Number.new(rate_center:, order_details: result, e164_format: "1#{result.number}") }
    end

    def initialize_filter
      Hash.new { |countries, country| countries[country] = Hash.new { |regions, region| regions[region] = [] } }
    end
  end
end
