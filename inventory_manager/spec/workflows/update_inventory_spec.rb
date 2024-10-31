require "spec_helper"

RSpec.describe UpdateInventory do
  it "generates a purchase order" do
    number = Struct.new(:number, :rate_center, :e164_format, :rate_center_attributes, keyword_init: true)

    purchase_order = build_purchase_order(
      {
        city: build_city(country: "US", region: "NY", name: "New York"),
        numbers: [
          number.new(number: "6468136545", e164_format: "16468136545", rate_center: "NWYRCYZN01", rate_center_attributes: { lata: "132", lat: "40.739362", long: "-73.991043" }),
          number.new(number: "6468136546", e164_format: "16468136546", rate_center: "NWYRCYZN03", rate_center_attributes: { lata: "132", lat: "40.739362", long: "-73.991043" })
        ]
      },
      {
        city: build_city(country: "US", region: "CA", name: "Los Angeles"),
        numbers: [
          number.new(number: "3322589357", e164_format: "13322589357", rate_center: "LSAN DA 01", rate_center_attributes: { lata: "730", lat: "34.050281", long: "-118.250995" }),
          number.new(number: "3322589358", e164_format: "13322589358", rate_center: "LSAN DA 01", rate_center_attributes: { lata: "730", lat: "34.050281", long: "-118.250995" })
        ]
      }
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
      latitude: "40.739362",
      longitude: "-73.991043",
      metadata: {
        provider_name: "skyetel",
        order_details: hash_including(
          number: "6468136545",
          ratecenter: "NWYRCYZN01",
        ),
        rate_center: hash_including(name: "NWYRCYZN01", lata: "132")
      }
    )
    expect(client).to have_received(:create_phone_number) { |args| expect(args.dig(:metadata, :rate_center)).not_to have_key(:closest_city) }.exactly(4).times
    expect(client).to have_received(:create_phone_number).with(
      hash_including(
        number: "16468136546",
        country: "US",
        region: "NY",
        locality: "New York",
        lata: "132",
        rate_center: "NWYRCYZN03",
        latitude: "40.739362",
        longitude: "-73.991043",
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
        latitude: "34.050281",
        longitude: "-118.250995",
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
        latitude: "34.050281",
        longitude: "-118.250995",
        metadata: hash_including(
          order_details: hash_including(
            number: "3322589358",
            ratecenter: "LSAN DA 01"
          )
        )
      )
    )
  end

  def build_purchase_order(*line_items)
    did = JSON.parse(file_fixture("skyetel/responses/search.json").read).dig("data", "result").first
    line_items = Array(line_items).map do |line_item|
      PurchaseOrder::LineItem.new(
        **line_item,
        numbers: line_item.fetch(:numbers).map do |number|
          closest_city = OpenStruct.new(name: "Manhattan", distance_km: 5.33)
          rate_center = OpenStruct.new(name: number.rate_center, closest_city:, **number.rate_center_attributes)
          order_details = OpenStruct.new(**did, number: number.number, ratecenter: number.rate_center)
          PurchaseOrder::Number.new(rate_center:, order_details:, e164_format: number.e164_format)
        end
      )
    end

    PurchaseOrder.new(line_items:)
  end

  def build_city(**attributes)
    SupportedCitiesParser::City.new(**attributes)
  end
end
