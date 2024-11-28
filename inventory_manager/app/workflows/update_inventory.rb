class UpdateInventory
  class RateCenterDecorator < SimpleDelegator
    def to_h
      super.each_with_object({}) do |(key, value), result|
        result[key] = value unless value.respond_to?(:to_h)
      end
    end
  end

  def self.call(...)
    new(...).call
  end

  attr_reader :purchase_order, :client, :number_visibility, :supplier

  def initialize(**options)
    @purchase_order = options.fetch(:purchase_order)
    @supplier = options.fetch(:supplier)
    @client = options.fetch(:client) { Somleng::Client.new }
    @number_visibility = options.fetch(:number_visibility) { AppSettings.fetch(:somleng_number_visibility) }
  end

  def call
    purchase_order.line_items.each do |line_item|
      line_item.numbers.each do |number|
        create_phone_number(number:, line_item:)
      end
    end
  end

  private

  def create_phone_number(number:, line_item:)
    client.create_phone_number(
      number: number.e164_format,
      type: :local,
      visibility: number_visibility,
      country: line_item.city.country,
      region: line_item.city.region,
      locality: line_item.city.name,
      lata: number.rate_center.lata,
      rate_center: number.rate_center.name,
      latitude: number.rate_center.lat,
      longitude: number.rate_center.long,
      metadata: {
        supplier: supplier.identifier,
        order_details: number.order_details.to_h,
        rate_center: RateCenterDecorator.new(number.rate_center).to_h
      }
    )
  end
end
