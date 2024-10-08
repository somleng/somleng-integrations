class RestockInventory
  PurchaseOrderLineItem = Struct.new(:country, :region, :name, :quantity)

  def self.call(...)
    new(...).call
  end

  def call
    inventory_report = GenerateInventoryReport.call

    AppSettings.supported_cities.map do |city|
      PurchaseOrderLineItem.new(
        country: city.country,
        region: city.region,
        name: city.name,
        quantity: inventory_report.cities.find_city_by(country: city.country, region: city.region, name: city.name).inventory_size
      )
    end
  end
end
