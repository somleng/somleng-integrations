require "spec_helper"
require "skyetel/data_source/rate_centers"

module Skyetel
  module DataSource
    RSpec.describe RateCenters do
      it "loads rate centers" do
        data_source = RateCenters.new(client: fake_client)
        data_directory = Pathname(File.expand_path("../../../../tmp/skyetel/us", __dir__))

        data_source.load_data!(data_directory:, states: "NY")
        output_data = YAML.load((data_directory.join("ny.yml").read))
        rate_centers = output_data.fetch("rate_centers")

        expect(rate_centers.size).to eq(JSON.parse(file_fixture("skyetel/responses/ratecenter.json").read).fetch("data").size)

        expect(rate_centers.first).to include(
          "country" => "US",
          "state" => "NY",
          "name" => be_a(String),
          "footprint_id" => be_a(Integer)
        )
      end

      def fake_client
        instance_double(
          Skyetel::Client,
          rate_centers: fake_response_from(:ratecenter),
          states: fake_response_from(:states)
        )
      end

      def fake_response_from(fixture_name)
        Response.new(
          data: JSON.parse(file_fixture("skyetel/responses/#{fixture_name}.json").read).fetch("data").map { |data| OpenStruct.new(**data) }
        )
      end
    end
  end
end
