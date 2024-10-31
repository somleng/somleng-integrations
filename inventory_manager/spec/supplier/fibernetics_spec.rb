require "spec_helper"

module Supplier
  RSpec.describe Fibernetics do
    require "pry"

    describe "#generate_purchase_order" do
      it "generates a purchase order" do
        shopping_list = build_shopping_list(
          { city: build_city(country: "CA", region: "MB", name: "Winnipeg", nearby_rate_centers: [ { name: "OAKBANK", region: "MB", country: "CA" } ]), quantity: 2 },
          { city: build_city(country: "CA", region: "ON", name: "Mapleton", nearby_rate_centers: [ { name: "DRAYTON", region: "ON", country: "CA" } ]), quantity: 2 }
        )

        fake_client = build_fake_client(
          available_npa_nxx: [
            { rc: "OAKBANK", region: "MB", country: "CA", npa: "204", nxx: "816" },
            { rc: "DRAYTON", region: "ON", country: "CA", npa: "226", nxx: "223" }
          ],
          available_tns: [
            [
              "2048160049",
              "2048161525",
              "2048162823"
            ],
            [
              "2262230049",
              "2262231525",
              "2262232823"
            ]
          ]
        )

        supplier = Fibernetics.new(client: fake_client)

        purchase_order = supplier.generate_purchase_order(shopping_list)

        expect(purchase_order.line_items.count).to eq(2)
        expect(purchase_order.line_items[0]).to have_attributes(
          city: have_attributes(
            country: "CA",
            region: "MB",
            name: "Winnipeg"
          ),
          numbers: contain_exactly(
            have_attributes(
              number: "2048160049",
              e164_format: "12048160049",
              rate_center: have_attributes(name: "OAKBANK"),
              order_details: "2048160049",
            ),
            have_attributes(
              number: "2048161525",
              e164_format: "12048161525",
              rate_center: have_attributes(name: "OAKBANK"),
              order_details: "2048161525",
            )
          )
        )
        expect(purchase_order.line_items[1]).to have_attributes(
          city: have_attributes(
            country: "CA",
            region: "ON",
            name: "Mapleton",
          ),
          numbers: contain_exactly(
            have_attributes(
              number: "2262230049",
              e164_format: "12262230049",
              rate_center: have_attributes(name: "DRAYTON"),
              order_details: "2262230049",
            ),
            have_attributes(
              number: "2262231525",
              e164_format: "12262231525",
              rate_center: have_attributes(name: "DRAYTON"),
              order_details: "2262231525"
            )
          )
        )

        expect(purchase_order.to_order).to eq([ "2048160049", "2048161525", "2262230049", "2262231525" ])
      end
    end

    def build_fake_client(**options)
      client = instance_double(
        ::Fibernetics::Client,
        available_npa_nxx: OpenStruct.new(data: options.fetch(:available_npa_nxx).map { |data| OpenStruct.new(**data) }),
      )
      allow(client).to receive(:available_tns).and_return(*options.fetch(:available_tns).map { |tns| OpenStruct.new(data: tns) })
      client
    end

    def build_shopping_list(*line_items)
      ShoppingList.new(line_items: Array(line_items).map { |line_item| ShoppingList::LineItem.new(**line_item) })
    end

    def build_city(**attributes)
      SupportedCitiesParser::City.new(**attributes, nearby_rate_centers: Array(attributes.fetch(:nearby_rate_centers)).map { |rate_center_attributes| OpenStruct.new(**rate_center_attributes) })
    end
  end
end
