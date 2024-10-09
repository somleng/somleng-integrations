require "spec_helper"

RSpec.describe GenerateShoppingList do
  it "generates a purchase order" do
    inventory_report = build_inventory_report(
      line_items: [
        { country: "US", region: "NY", locality: "New York", quantity: 10 },
        { country: "US", region: "CA", locality: "Los Angeles", quantity: 65 },
        { country: "AU", region: "VIC", locality: "Melbourne", quantity: 65 }
      ]
    )

    shopping_list = GenerateShoppingList.call(inventory_report:, max_stock: 100)

    expect(shopping_list.line_items.size).to eq(20)
    expect(shopping_list.line_items[0]).to have_attributes(
      country: "US",
      region: "NY",
      locality: "New York",
      quantity: 90,
      nearby_rate_centers: be_a(Array)
    )
    expect(shopping_list.line_items[1]).to have_attributes(
      country: "US",
      region: "CA",
      locality: "Los Angeles",
      quantity: 35,
      nearby_rate_centers: be_a(Array)
    )
    expect(shopping_list.line_items.map(&:locality)).not_to include("Melbourne")
  end

  def build_inventory_report(line_items:)
    InventoryReport.new(line_items: Array(line_items).map { |line_item| InventoryReport::LineItem.new(**line_item) })
  end
end
