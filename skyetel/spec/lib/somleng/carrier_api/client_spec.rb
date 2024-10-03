require "spec_helper"

module Somleng
  module CarrierAPI
    RSpec.describe Client do
      describe "phone_number_stats" do
        it "returns phone number stats" do
          client = Client.new
          stub_api_request(
            :get, "https://api.somleng.org/carrier/v1/phone_numbers/stats",
            response_body: response_fixture(:stats)
          )

          response = client.phone_number_stats(
            filter: {
              available: true, type: :local
            },
            group_by: [ :country, :region, :locality ]
          )

          response.data.each do |data|
            expect(data).to have_attributes(
              id: be_a(String),
              attributes: be_a(Hash),
              type: be_a(String)
            )
          end
          expect(
            a_request(:get, %r{https://api.somleng.org/carrier/v1/phone_numbers/stats}).with { |req|
              query = Rack::Utils.parse_nested_query(req.uri.query)
              expect(query).to include(
                "filter" => {
                  "available" => "true",
                  "type" => "local"
                },
                "group_by" => contain_exactly("country", "region", "locality"),
                "page" => {
                  "size" => "100"
                }
              )
              true
            }
          ).to have_been_made
        end

        it "handles pagination" do
          client = Client.new
          response_body = response_fixture(:stats)
          total_records = JSON.parse(response_body).fetch("data").size
          page_size = 2
          stub_api_request(
            :get, "https://api.somleng.org/carrier/v1/phone_numbers/stats",
            response_body:
          )

          response = client.phone_number_stats(
            filter: {
              available: true, type: :local, country: "US"
            },
            group_by: [ :country, :region, :locality ],
            page: {
              size: page_size
            }
          )

          expect(response.data.size).to eq(page_size)
          expect(response.data.auto_paging_each.map(&:id).size).to eq(total_records)
          expect(
            a_request(:get, %r{https://api.somleng.org/carrier/v1/phone_numbers/stats}).with { |req|
              query = Rack::Utils.parse_nested_query(req.uri.query)
              expect(query).to include(
                "filter" => {
                  "available" => "true",
                  "type" => "local",
                  "country" => "US"
                },
                "group_by" => contain_exactly("country", "region", "locality"),
                "page" => include("size" => page_size.to_s)
              )
              true
            }
          ).to have_been_made.times((total_records / page_size.to_f).ceil)
        end
      end

      def response_fixture(name)
        file_fixture("somleng/carrier_api/responses/phone_numbers/#{name}.json").read
      end
    end
  end
end
