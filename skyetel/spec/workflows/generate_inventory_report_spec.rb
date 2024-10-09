require "spec_helper"

RSpec.describe GenerateInventoryReport do
  it "generates an inventory report" do
    report = GenerateInventoryReport.call(client: fake_client)

    expect(report.line_items).to be_a(Array)
    report.line_items.each do |city|
      expect(city).to have_attributes(
        locality: be_a(String),
        region: be_a(String),
        country: be_a(String),
        quantity: be_a(Integer)
      )
    end
  end

  def fake_client
    client = instance_double(Somleng::CarrierAPI::Client)
    allow(client).to receive(:phone_number_stats).and_return(fake_response_from(:phone_number_stats, client:))
    client
  end

  def fake_response_from(fixture_name, **)
    JSONAPI::ResponseParser.new.parse(JSON.parse(file_fixture("somleng/responses/#{fixture_name}.json").read), **)
  end
end
