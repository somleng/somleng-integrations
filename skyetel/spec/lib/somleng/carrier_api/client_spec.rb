require "spec_helper"
require "somleng"

module Somleng
  module CarrierAPI
    RSpec.describe Client do
      describe "phone_number_stats" do
        it "works" do
          client = Client.new

          client.phone_number_stats
        end
      end
    end
  end
end
