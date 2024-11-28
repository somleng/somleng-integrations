require "spec_helper"

module Skyetel
  RSpec.describe DataLoader do
    it "loads all rate centers" do
      data_loader = DataLoader.new

      data_loader.load(:rate_centers, :all)

      expect(data_loader.rate_centers.size).to be_positive
    end

    it "supports filtering rate centers by country" do
      data_loader = DataLoader.new

      data_loader.load(:rate_centers, only: :us)

      expect(data_loader.rate_centers.map { |data| data.fetch("country") }.uniq).to eq([ "US" ])
    end

    it "supports filtering rate centers by state" do
      data_loader = DataLoader.new

      data_loader.load(:rate_centers, only: { us: :ny })

      expect(data_loader.rate_centers.map { |data| data.fetch("state") }.uniq).to eq([ "NY" ])
    end

    it "supports filtering specific rate centers" do
      data_loader = DataLoader.new

      data_loader.load(:rate_centers, only: { us: { ny: "NWYRCYZN01", ca: "LSAN DA 01" } })

      expect(data_loader.rate_centers.size).to eq(2)

      expect(data_loader.rate_centers[0]).to include(
        "country" => "US",
        "state" => "NY",
        "name" => "NWYRCYZN01"
      )

      expect(data_loader.rate_centers[1]).to include(
        "country" => "US",
        "state" => "CA",
        "name" => "LSAN DA 01"
      )
    end

    it "handles reloading" do
      data_loader = DataLoader.new

      data_loader.load(:rate_centers, only: { us: { ny: "NWYRCYZN01" } })
      expect(data_loader.rate_centers.size).to eq(1)

      data_loader.load(:rate_centers, only: { us: [ :ny ] })
      expect(data_loader.rate_centers.size).to be > 1
    end
  end
end
