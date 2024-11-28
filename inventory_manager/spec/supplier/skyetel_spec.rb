require "spec_helper"

module Supplier
  RSpec.describe Skyetel do
    describe "#generate_purchase_order" do
      it "generates a purchase order" do
        shopping_list = build_shopping_list(
          { city: build_city(country: "US", region: "NY", name: "New York", nearby_rate_centers: [ "NWYRCYZN01", "NWYRCYZN03" ]), quantity: 2 },
          { city: build_city(country: "US", region: "CA", name: "Los Angeles",  nearby_rate_centers: [ "BEVERLYHLS" ]), quantity: 2}
        )

        search_result = Struct.new(:results, :for)

        fake_client = build_fake_client(
          search: [
            search_result.new(results: 1, for: "NWYRCYZN01"),
            search_result.new(results: 5, for: "NWYRCYZN03"),
            search_result.new(results: 4, for: "BEVERLYHLS")
          ]
        )

        supplier = Skyetel.new(client: fake_client)

        purchase_order = supplier.generate_purchase_order(shopping_list)

        expect(purchase_order.line_items.count).to eq(2)
        expect(purchase_order.line_items[0]).to have_attributes(
          city: have_attributes(
            country: "US",
            region: "NY",
            name: "New York"
          ),
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
          city: have_attributes(
            country: "US",
            region: "CA",
            name: "Los Angeles",
          ),
          numbers: contain_exactly(
            have_attributes(
              rate_center: have_attributes(name: "BEVERLYHLS"),
              order_details: have_attributes(ratecenter: "BEVERLYHLS")
            ),
            have_attributes(
              rate_center: have_attributes(name: "BEVERLYHLS"),
              order_details: have_attributes(ratecenter: "BEVERLYHLS")
            )
          )
        )

        expect(purchase_order.to_order.map(&:ratecenter)).to eq([ "NWYRCYZN01", "NWYRCYZN03", "BEVERLYHLS", "BEVERLYHLS" ])
      end

      it "handles timeout errors" do
        shopping_list = build_shopping_list(
          { city: build_city(country: "US", region: "NY", name: "New York", nearby_rate_centers: [ "NWYRCYZN03" ]), quantity: 1 },
        )

        fake_client = instance_spy(::Skyetel::Client)
        allow(fake_client).to receive(:search).and_raise(::Skyetel::Errors::TimeoutError)

        supplier = Skyetel.new(client: fake_client)

        purchase_order = supplier.generate_purchase_order(shopping_list)
        expect(purchase_order.line_items).to be_empty
      end
    end

    describe "#execute_order" do
      it "executes a purchase order" do
        purchase_order = instance_double(PurchaseOrder, to_order: [])
        fake_client = instance_spy(::Skyetel::Client)
        supplier = Skyetel.new(client: fake_client)

        supplier.execute_order(purchase_order)

        expect(fake_client).to have_received(:purchase).with(type: :local, numbers: [])
      end

      it "handles empty purchase orders" do
        purchase_order = instance_double(PurchaseOrder, to_order: [])
        fake_client = instance_spy(::Skyetel::Client)
        supplier = Skyetel.new(client: fake_client)

        supplier.execute_order(purchase_order)

        expect(fake_client).not_to have_received(:purchase)
      end
    end

    def build_fake_client(**options)
      client = instance_double(::Skyetel::Client)

      allow(client).to receive(:search) do |params|
        response = JSON.parse(file_fixture("skyetel/responses/search.json").read)
        did_result = response.dig("data", "result").first
        results = []
        search_result = options.fetch(:search).find { |result| result.for == params.fetch(:rate_center) }
        search_result.results.times { results << did_result.merge("ratecenter" => search_result.for) }
        ::Skyetel::Client::SearchResponseParser.new.parse("data" => { "result" => results })
      end
      client
    end

    def build_shopping_list(*line_items)
      ShoppingList.new(line_items: Array(line_items).map { |line_item| ShoppingList::LineItem.new(**line_item) })
    end

    def build_city(**attributes)
      SupportedCitiesParser::City.new(**attributes, nearby_rate_centers: Array(attributes.fetch(:nearby_rate_centers)).map { |rate_center| OpenStruct.new(name: rate_center) })
    end
  end
end
