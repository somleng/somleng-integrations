class ShoppingList
  LineItem = Struct.new(:city, :quantity)

  attr_reader :line_items, :cities, :min_stock, :max_stock

  def initialize(**options)
    @line_items = Array(options.fetch(:line_items))
    @cities = options[:cities]
    @min_stock = options[:min_stock]
    @max_stock = options[:max_stock]
  end
end
