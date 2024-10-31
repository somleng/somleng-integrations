require "spec_helper"

module Fibernetics
  RSpec.describe Client do
    describe "#available_npa_nxx" do
      it "returns a list of available NPA NXX" do
        client = Client.new(api_token: "api-token")

        stub_api_request(
          :get,
          "https://api.fibernetics.ca/api/did-management/available-npa-nxx",
          response_body: file_fixture("fibernetics/responses/available-npa-nxx.json").read
        )

        response = client.available_npa_nxx

        response.data.each do |data|
          expect(data).to have_attributes(
            country: be_a(String),
            region: be_a(String),
            rc: be_a(String)
          )
        end

        expect(
          a_request(
            :get, %r{https://api.fibernetics.ca/api/did-management/available-npa-nxx}
          ).with(headers: { "X-Wapig-Api-Token" => "api-token" })
        ).to have_been_made
      end
    end

    describe "#available_tns" do
      it "returns a list of available tns for the given NPA/NXX" do
        client = Client.new(api_token: "api-token")

        stub_api_request(
          :get,
          "https://api.fibernetics.ca/api/did-management/available-tns",
          response_body: file_fixture("fibernetics/responses/available-tns.json").read
        )

        response = client.available_tns(npa: "204", nxx: "816")

        expect(response.data).to be_a(Array)
        expect(response.data.first).to be_a(String)
        expect(
          a_request(
            :get, %r{https://api.fibernetics.ca/api/did-management/available-tns}
          ).with(query: { "npa" => "204", "nxx" => "816" }, headers: { "X-Wapig-Api-Token" => "api-token" })
        ).to have_been_made
      end
    end
  end
end
