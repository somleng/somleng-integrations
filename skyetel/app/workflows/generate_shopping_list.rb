class GenerateShoppingList
  def self.call(...)
    new(...).call
  end

  attr_reader :inventory_report, :max_stock, :cities

  def initialize(**options)
    @inventory_report = options.fetch(:inventory_report)
    @max_stock = options.fetch(:max_stock) { ENV.fetch("MAX_STOCK", 100) }
    @cities = options.fetch(:cities) { AppSettings.supported_cities }
  end

  def call
    ShoppingList.new(line_items: cities.map { |city| build_line_item_from(city) })
  end

  private

  def build_line_item_from(city)
    inventory_item = inventory_report.find_line_item_by(
      country: city.country,
      region: city.region,
      locality: city.name
    )
    current_stock = inventory_item ? inventory_item.quantity : 0
    desired_quantity = [ (max_stock - current_stock), max_stock ].min

    ShoppingList::LineItem.new(
      country: city.country,
      region: city.region,
      locality: city.name,
      quantity: desired_quantity,
      nearby_rate_centers: city.nearby_rate_centers
    )
  end
end
