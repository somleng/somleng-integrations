class GeneratePurchaseOrder
  def self.call(...)
    new(...).call
  end

  attr_reader :shopping_list, :client

  def initialize(**options)
    @shopping_list = options.fetch(:shopping_list)
    @client = options.fetch(:client) { Skyetel::Client.new }
  end

  def call
    line_items = shopping_list.line_items.each_with_object([]) do |shopping_list_line_item, result|
      numbers = shopping_list_line_item.nearby_rate_centers.each_with_object([]) do |rate_center, dids|
        search_result = find_dids_for(shopping_list_line_item:, rate_center:)
        dids.concat(search_result.data)
        dids.size < shopping_list_line_item.quantity ? next : (break dids)
      end

      result << build_line_item(
        order_details: numbers.first(shopping_list_line_item.quantity),
        shopping_list_line_item:
      )
    end

    PurchaseOrder.new(line_items:)
  end

  private

  def find_dids_for(shopping_list_line_item:, rate_center:)
    client.search(
      type: :local,
      state: shopping_list_line_item.region,
      rate_center: rate_center.name,
      limit: shopping_list_line_item.quantity
    )
  end

  def build_line_item(order_details:, shopping_list_line_item:)
    PurchaseOrder::LineItem.new(
      country: shopping_list_line_item.country,
      region: shopping_list_line_item.region,
      locality: shopping_list_line_item.locality,
      order_details:,
    )
  end
end
