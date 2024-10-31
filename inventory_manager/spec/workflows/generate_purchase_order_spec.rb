require "spec_helper"

RSpec.describe GeneratePurchaseOrder do
  it "generates a purchase order" do
    shopping_list = build_shopping_list(
      line_items: [
        { country: "US", region: "NY", locality: "New York", quantity: 2, nearby_rate_centers: [ "NWYRCYZN01", "NWYRCYZN03" ] },
        { country: "US", region: "CA", locality: "Los Angeles", quantity: 2, nearby_rate_centers: [ "LSAN DA 01" ] }
      ]
    )

    search_result = Class.new(Struct.new(:results, :for))

    fake_client = build_fake_client(
      search: [
        search_result.new(results: 1, for: "NWYRCYZN01"),
        search_result.new(results: 5, for: "NWYRCYZN03"),
        search_result.new(results: 4, for: "LSAN DA 01")
      ]
    )

    purchase_order = GeneratePurchaseOrder.call(shopping_list: shopping_list, client: fake_client)

    expect(purchase_order.line_items.count).to eq(2)
    expect(purchase_order.line_items[0]).to have_attributes(
      country: "US",
      region: "NY",
      locality: "New York",
      numbers: contain_exactly(
        have_attributes(
          rate_center: have_attributes(name: "NWYRCYZN01"),
          order_details: have_attributes(ratecenter: "NWYRCYZN01")
        ),
        have_attributes(
          rate_center: have_attributes(name: "NWYRCYZN03"),
          order_details: have_attributes(ratecenter: "NWYRCYZN03")
        )
      )
    )
    expect(purchase_order.line_items[1]).to have_attributes(
      country: "US",
      region: "CA",
      locality: "Los Angeles",
      numbers: contain_exactly(
        have_attributes(
          rate_center: have_attributes(name: "LSAN DA 01"),
          order_details: have_attributes(ratecenter: "LSAN DA 01")
        ),
        have_attributes(
          rate_center: have_attributes(name: "LSAN DA 01"),
          order_details: have_attributes(ratecenter: "LSAN DA 01")
        )
      )
    )

    expect(purchase_order.to_order.map(&:ratecenter)).to eq([ "NWYRCYZN01", "NWYRCYZN03", "LSAN DA 01", "LSAN DA 01" ])
  end

  def build_fake_client(**options)
    client = instance_double(Skyetel::Client)

    allow(client).to receive(:search) do |params|
      response = JSON.parse(file_fixture("skyetel/responses/search.json").read)
      did_result = response.dig("data", "result").first
      results = []
      search_result = options.fetch(:search).find { |result| result.for == params.fetch(:rate_center) }
      search_result.results.times { results << did_result.merge("ratecenter" => search_result.for) }
      Skyetel::Client::SearchResponseParser.new.parse("data" => { "result" => results })
    end
    client
  end

  def build_shopping_list(line_items:)
    line_items = Array(line_items).map do |line_item|
      ShoppingList::LineItem.new(
        **line_item,
        nearby_rate_centers: Array(line_item.fetch(:nearby_rate_centers)).map { |rate_center| OpenStruct.new(name: rate_center) }
      )
    end

    ShoppingList.new(line_items:)
  end
end
