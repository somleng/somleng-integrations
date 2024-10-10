class GenerateShoppingList
  def self.call(...)
    new(...).call
  end

  attr_reader :inventory_report, :min_stock, :max_stock, :cities

  def initialize(**options)
    @inventory_report = options.fetch(:inventory_report)
    @min_stock = options.fetch(:min_stock) { ENV.fetch("MIN_STOCK", 50) }
    @max_stock = options.fetch(:max_stock) { ENV.fetch("MAX_STOCK", 100) }
    @cities = options.fetch(:cities) { AppSettings.supported_cities }
  end

  def call
    line_items = cities.each_with_object([]) do |city, result|
      inventory_item = inventory_report.find_line_item_by(
        country: city.country,
        region: city.region,
        locality: city.name
      )
      current_stock = inventory_item ? inventory_item.quantity : 0

      next if current_stock >= min_stock

      result << ShoppingList::LineItem.new(
        country: city.country,
        region: city.region,
        locality: city.name,
        quantity: max_stock - current_stock,
        nearby_rate_centers: city.nearby_rate_centers
      )
    end

    ShoppingList.new(line_items:)
  end
end
