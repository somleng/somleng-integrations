class GeneratePurchaseOrder
  def self.call(...)
    new(...).call
  end

  attr_reader :shopping_list, :client

  def initialize(**options)
    @shopping_list = options.fetch(:shopping_list)
    @client = options.fetch(:client)
  end

  def call
    line_items = shopping_list.line_items.each_with_object([]) do |line_item, result|
      line_item.nearby_rate_centers.each_with_object([]) do |rate_center, dids|
        search_result = find_dids_for(line_item:, rate_center:)

        dids.concat(search_result.data)

        if dids.size >= line_item.quantity
          result.concat(dids.first(line_item.quantity))
          break
        end
      end
    end

    PurchaseOrder.new(line_items:)
  end

  private

  def find_dids_for(line_item:, rate_center:)
    client.search(
      type: :local,
      state: line_item.region,
      rate_center: rate_center.name,
      limit: line_item.quantity
    )
  end
end
