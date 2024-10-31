require "spec_helper"

RSpec.describe GenerateShoppingList do
  it "generates a shopping list" do
    inventory_report = build_inventory_report(
      line_items: [
        { country: "US", region: "NY", locality: "New York", quantity: 49 },
        { country: "US", region: "CA", locality: "Los Angeles", quantity: 50 },
        { country: "AU", region: "VIC", locality: "Melbourne", quantity: 1 }
      ]
    )

    cities = SupportedCitiesParser.new(
      data: [
        { "country" => "US", "region" => "NY", "name" => "New York" },
        { "country" => "US", "region" => "CA", "name" => "Los Angeles" }
      ]
    ).parse

    shopping_list = GenerateShoppingList.call(cities:, inventory_report:, min_stock: 50, max_stock: 100)

    expect(shopping_list.line_items.size).to eq(1)
    expect(shopping_list.line_items[0]).to have_attributes(
      city: have_attributes(
        country: "US",
        region: "NY",
        name: "New York"
      ),
      quantity: 51
    )
  end

  def build_inventory_report(line_items:)
    InventoryReport.new(line_items: Array(line_items).map { |line_item| InventoryReport::LineItem.new(**line_item) })
  end
end
