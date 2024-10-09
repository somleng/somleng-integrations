require "spec_helper"

RSpec.describe UpdateInventory do
  it "generates a purchase order" do
    number = Class.new(Struct.new(:number, :ratecenter, keyword_init: true))

    purchase_order = build_purchase_order(
      line_items: [
        {
          country: "US", region: "NY", locality: "New York",
          order_details: [
            number.new(number: "6468136545", ratecenter: "NWYRCYZN01"),
            number.new(number: "6468136546", ratecenter: "NWYRCYZN03")
          ]
        },
        {
          country: "US", region: "CA", locality: "Los Angeles",
          order_details: [
            number.new(number: "3322589357", ratecenter: "LSAN DA 01"),
            number.new(number: "3322589358", ratecenter: "LSAN DA 01")
          ]
        }
      ]
    )

    client = instance_spy(Somleng::CarrierAPI::Client)

    UpdateInventory.call(purchase_order:, client:)

    expect(client).to have_received(:create_phone_number).exactly(4).times
    expect(client).to have_received(:create_phone_number).with(
      number: "16468136545",
      type: :local,
      visibility: "public",
      country: "US",
      region: "NY",
      locality: "New York",
      metadata: {
        provider_name: "skyetel",
        provider_attributes: hash_including(
          number: "6468136545",
          ratecenter: "NWYRCYZN01"
        )
      }
    )
    expect(client).to have_received(:create_phone_number).with(
      hash_including(
        number: "16468136546",
        country: "US",
        region: "NY",
        locality: "New York",
        metadata: hash_including(
          provider_attributes: hash_including(
            number: "6468136546",
            ratecenter: "NWYRCYZN03"
          )
        )
      )
    )
    expect(client).to have_received(:create_phone_number).with(
      hash_including(
        number: "13322589357",
        country: "US",
        region: "CA",
        locality: "Los Angeles",
        metadata: hash_including(
          provider_attributes: hash_including(
            number: "3322589357",
            ratecenter: "LSAN DA 01"
          )
        )
      )
    )
    expect(client).to have_received(:create_phone_number).with(
      hash_including(
        number: "13322589358",
        country: "US",
        region: "CA",
        locality: "Los Angeles",
        metadata: hash_including(
          provider_attributes: hash_including(
            number: "3322589358",
            ratecenter: "LSAN DA 01"
          )
        )
      )
    )
  end

  def build_purchase_order(line_items:)
    did = JSON.parse(response_fixture(:search).read).dig("data", "result").first
    line_items = Array(line_items).map do |line_item|
      PurchaseOrder::LineItem.new(
        **line_item,
        order_details: line_item.fetch(:order_details).map { |number| OpenStruct.new(**did, number: number.number, ratecenter: number.ratecenter) }
      )
    end

    PurchaseOrder.new(line_items:)
  end


  def response_fixture(name)
    file_fixture("skyetel/responses/#{name}.json")
  end
end
