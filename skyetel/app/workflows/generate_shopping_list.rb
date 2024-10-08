class GenerateShoppingList
  def self.call(...)
    new(...).call
  end

  attr_reader :inventory_report, :max_stock

  def initialize(**options)
    @inventory_report = options.fetch(:inventory_report)
    @max_stock = options.fetch(:max_stock) { ENV.fetch("MAX_STOCK", 100) }
  end

  def call
    generate_purchase_order
  end

  private

  def generate_purchase_order
    ShoppingList.new(line_items: AppSettings.supported_cities.map { |city| build_line_item_from(city) })
  end

  def build_line_item_from(city)
    inventory_item = inventory_report.find_line_item_by(
      country: city.country,
      region: city.region,
      name: city.name
    )
    current_stock = inventory_item ? inventory_item.quantity : 0
    desired_quantity = [ (max_stock - current_stock), max_stock ].min

    ShoppingList::LineItem.new(
      country: city.country,
      region: city.region,
      name: city.name,
      quantity: desired_quantity,
      nearby_rate_centers: city.nearby_rate_centers
    )
  end
end
