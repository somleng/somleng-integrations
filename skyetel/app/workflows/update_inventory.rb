class UpdateInventory
  def self.call(...)
    new(...).call
  end

  attr_reader :purchase_order, :client, :country_calling_code, :number_visibility, :provider_name

  def initialize(**options)
    @purchase_order = options.fetch(:purchase_order)
    @client = options.fetch(:client) { Somleng::Client.new }
    @country_calling_code = options.fetch(:country_calling_code, "1")
    @number_visibility = options.fetch(:number_visibility) { ENV.fetch("NUMBER_VISIBILITY", "public") }
    @provider_name = options.fetch(:provider_name, "skyetel")
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
      number: "#{country_calling_code}#{number.order_details.number}",
      type: :local,
      visibility: number_visibility,
      country: line_item.country,
      region: line_item.region,
      locality: line_item.locality,
      lata: number.rate_center.lata,
      rate_center: number.rate_center.name,
      metadata: {
        provider_name:,
        order_details: number.order_details.to_h
      }
    )
  end
end
