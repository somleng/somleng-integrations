class ShoppingList
  LineItem = Struct.new(:country, :region, :locality, :quantity, :nearby_rate_centers)

  attr_reader :line_items

  def initialize(line_items:)
    @line_items = Array(line_items)
  end
end
