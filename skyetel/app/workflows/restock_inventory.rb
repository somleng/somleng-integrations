require "pry"

class RestockInventory
  def self.call(...)
    new(...).call
  end

  attr_reader :somleng_client, :skyetel_client

  def initialize(**options)
    @somleng_client = options.fetch(:somleng_client) { Somleng::CarrierAPI::Client.new }
    @skyetel_client = options.fetch(:skyetel_client) { Skyetel::Client.new }
  end

  def call
    inventory_report = GenerateInventoryReport.call(client: somleng_client)
    shopping_list = GenerateShoppingList.call(inventory_report:)
    purchase_order = GeneratePurchaseOrder.call(shopping_list:, client: skyetel_client)
    ExecuteOrder.call(purchase_order:, client: skyetel_client)
    UpdateInventory.call(purchase_order:, client: somleng_client)
  end
end
