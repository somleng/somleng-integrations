class PurchaseOrder
  LineItem = Struct.new(:country, :region, :locality, :order_details, keyword_init: true)

  attr_reader :line_items

  def initialize(line_items:)
    @line_items = Array(line_items)
  end

  def to_order
    line_items.each_with_object([]) do |line_item, result|
      result.concat(line_item.order_details)
    end
  end
end
