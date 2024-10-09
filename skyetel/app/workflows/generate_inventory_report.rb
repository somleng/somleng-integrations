class GenerateInventoryReport
  def self.call(...)
    new(...).call
  end

  attr_reader :client, :min_stock

  def initialize(**options)
    @client = options.fetch(:client) { Somleng::CarrierAPI::Client.new }
    @min_stock = options.fetch(:min_stock) { ENV.fetch("MIN_STOCK", 50) }
  end

  def call
    generate_inventory_report
  end

  private

  def generate_inventory_report
    line_items = phone_number_stats.data.auto_paging_each.each_with_object([]) do |data, result|
      statistic = data.attributes.fetch("statistic")
      next unless statistic.all? { |_k, v| !v.nil? }

      result << build_line_item_from(statistic)
    end

    InventoryReport.new(line_items:)
  end

  def phone_number_stats
    @phone_number_stats ||= client.phone_number_stats(
      filter: {
        available: true, type: :local
      },
      group_by: [ :country, :region, :locality ],
      having: {
        count: { lt: min_stock }
      }
    )
  end

  def build_line_item_from(data)
    InventoryReport::LineItem.new(
      country: data.fetch("country"),
      region: data.fetch("region"),
      locality: data.fetch("locality"),
      quantity: data.fetch("value")
    )
  end
end
