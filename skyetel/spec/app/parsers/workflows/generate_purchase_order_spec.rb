require "spec_helper"

RSpec.describe GeneratePurchaseOrder do
  it "generates a purchase order" do
    inventory_report = build_inventory_report(
      line_items: [
        { country: "US", region: "NY", name: "New York", quantity: 10 },
        { country: "US", region: "CA", name: "Los Angeles", quantity: 65 },
        { country: "AU", region: "VIC", name: "Melbourne", quantity: 65 }
      ]
    )

    purchase_order = GeneratePurchaseOrder.call(inventory_report:, max_stock: 100)

    expect(purchase_order.line_items.size).to eq(20)
    expect(purchase_order.line_items[0]).to have_attributes(
      country: "US",
      region: "NY",
      name: "New York",
      quantity: 90,
      nearby_rate_centers: be_a(Array)
    )
    expect(purchase_order.line_items[1]).to have_attributes(
      country: "US",
      region: "CA",
      name: "Los Angeles",
      quantity: 35,
      nearby_rate_centers: be_a(Array)
    )
    expect(purchase_order.line_items.map(&:name)).not_to include("Melbourne")
  end

  def build_inventory_report(line_items:)
    InventoryReport.new(line_items: Array(line_items).map { |line_item| InventoryReport::LineItem.new(**line_item) })
  end
end
