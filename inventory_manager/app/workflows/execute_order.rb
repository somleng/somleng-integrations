class ExecuteOrder
  def self.call(...)
    new(...).call
  end

  attr_reader :purchase_order, :client

  def initialize(**options)
    @purchase_order = options.fetch(:purchase_order)
    @client = options.fetch(:client) { Skyetel::Client.new }
  end

  def call
    client.purchase(type: :local, numbers: purchase_order.to_order)
  end
end
