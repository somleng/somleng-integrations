class PurchaseOrder
  LineItem = Struct.new(:city, :numbers, keyword_init: true)
  Number = Struct.new(:rate_center, :order_details, :e164_format, keyword_init: true)

  attr_reader :line_items

  def initialize(line_items:)
    @line_items = Array(line_items)
  end

  def to_order
    line_items.each_with_object([]) do |line_item, result|
      result.concat(line_item.numbers.map(&:order_details))
    end
  end
end
