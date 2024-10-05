require "spec_helper"

RSpec.describe SupportedCitiesParser do
  describe "#parse" do
    it "parses the supported cities" do
      data_file = Pathname(File.expand_path("../../config/supported_cities.sample.csv", __dir__))
      parser = SupportedCitiesParser.new(data_file:)

      results = parser.parse

      expect(results.size).to eq(20)
      expect(results.first).to have_attributes(
        country: "US",
        region: "NY",
        name: "New York",
        nearby_rate_centers: be_a(Array)
      )
    end
  end
end
