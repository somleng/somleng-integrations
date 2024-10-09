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
      line_item.order_details.each do |number_details|
        create_phone_number(number_details:, line_item:)
      end
    end
  end

  private

  def create_phone_number(number_details:, line_item:)
    client.create_phone_number(
      number: "#{country_calling_code}#{number_details.number}",
      type: :local,
      visibility: number_visibility,
      country: line_item.country,
      region: line_item.region,
      locality: line_item.locality,
      metadata: {
        provider_name:,
        provider_attributes: number_details.to_h
      }
    )
  end
end
