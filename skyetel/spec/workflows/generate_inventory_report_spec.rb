require "spec_helper"

RSpec.describe GenerateInventoryReport do
  it "generates an inventory report" do
    report = GenerateInventoryReport.call(client: fake_client)

    expect(report.line_items).to be_a(Array)
    report.line_items.each do |city|
      expect(city).to have_attributes(
        name: be_a(String),
        region: be_a(String),
        country: be_a(String),
        quantity: be_a(Integer)
      )
    end
  end

  def fake_client
    client = instance_double(Somleng::CarrierAPI::Client)
    allow(client).to receive(:phone_number_stats).and_return(fake_response_from(:stats, client:))
    client
  end

  def fake_response_from(fixture_name, **)
    JSONAPI::ResponseParser.new.parse(JSON.parse(response_fixture(fixture_name).read), **)
  end

  def response_fixture(name)
    file_fixture("somleng/carrier_api/responses/phone_numbers/#{name}.json")
  end
end
