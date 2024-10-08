class InventoryReport
  LineItem = Struct.new(:country, :region, :name, :quantity, keyword_init: true)

  attr_reader :line_items

  def initialize(line_items:)
    @line_items = Array(line_items)
  end

  def find_line_item_by(attributes)
    line_items.find do |line_item|
      attributes.all? { |key, value| line_item[key] == value }
    end
  end
end
