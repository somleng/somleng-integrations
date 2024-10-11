class GenerateInventoryReport
  def self.call(...)
    new(...).call
  end

  attr_reader :client, :cities

  def initialize(**options)
    @client = options.fetch(:client) { Somleng::CarrierAPI::Client.new }
    @cities = options.fetch(:cities) { AppSettings.supported_cities }
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
      filter: build_filter,
      group_by: [ :country, :region, :locality ]
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

  def build_filter
    filter = {}
    countries = cities.map(&:country).uniq
    country = countries.first if countries.size == 1
    filter[:available] = true
    filter[:type] = :local
    filter[:country] = country if country
    filter
  end
end
