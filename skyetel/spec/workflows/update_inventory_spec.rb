require "spec_helper"

RSpec.describe UpdateInventory do
  it "generates a purchase order" do
    number = Class.new(Struct.new(:number, :rate_center, :rate_center_attributes, keyword_init: true))

    purchase_order = build_purchase_order(
      line_items: [
        {
          country: "US", region: "NY", locality: "New York",
          numbers: [
            number.new(number: "6468136545", rate_center: "NWYRCYZN01", rate_center_attributes: { lata: "132" }),
            number.new(number: "6468136546", rate_center: "NWYRCYZN03", rate_center_attributes: { lata: "132" })
          ]
        },
        {
          country: "US", region: "CA", locality: "Los Angeles",
          numbers: [
            number.new(number: "3322589357", rate_center: "LSAN DA 01", rate_center_attributes: { lata: "730" }),
            number.new(number: "3322589358", rate_center: "LSAN DA 01", rate_center_attributes: { lata: "730" })
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
      lata: "132",
      rate_center: "NWYRCYZN01",
      metadata: {
        provider_name: "skyetel",
        order_details: hash_including(
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
        lata: "132",
        rate_center: "NWYRCYZN03",
        metadata: hash_including(
          order_details: hash_including(
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
        lata: "730",
        rate_center: "LSAN DA 01",
        metadata: hash_including(
          order_details: hash_including(
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
        lata: "730",
        rate_center: "LSAN DA 01",
        metadata: hash_including(
          order_details: hash_including(
            number: "3322589358",
            ratecenter: "LSAN DA 01"
          )
        )
      )
    )
  end

  def build_purchase_order(line_items:)
    did = JSON.parse(file_fixture("skyetel/responses/search.json").read).dig("data", "result").first
    line_items = Array(line_items).map do |line_item|
      PurchaseOrder::LineItem.new(
        **line_item,
        numbers: line_item.fetch(:numbers).map do |number|
          rate_center = OpenStruct.new(name: number.rate_center, **number.rate_center_attributes)
          order_details = OpenStruct.new(**did, number: number.number, ratecenter: number.rate_center)
          PurchaseOrder::Number.new(rate_center:, order_details:)
        end
      )
    end

    PurchaseOrder.new(line_items:)
  end
end
