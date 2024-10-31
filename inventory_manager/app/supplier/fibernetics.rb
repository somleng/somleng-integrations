module Supplier
  class Fibernetics
    attr_reader :client

    def initialize(**options)
      @client = options.fetch(:client) { ::Fibernetics::Client.new }
    end

    def generate_purchase_order(shopping_list)
      line_items = shopping_list.line_items.map do |shopping_list_line_item|
        numbers = shopping_list_line_item.city.nearby_rate_centers.each_with_object([]) do |rate_center, dids|
          did_block = find_npa_nxx_for(rate_center)

          next unless did_block

          dids.concat(available_numbers_for(npa: did_block.npa, nxx: did_block.nxx, rate_center:))
          dids.size < shopping_list_line_item.quantity ? next : (break dids)
        end

        PurchaseOrder::LineItem.new(
          city: shopping_list_line_item.city,
          numbers: numbers.first(shopping_list_line_item.quantity)
        )
      end

      PurchaseOrder.new(line_items:)
    end

    private

    def available_npa_nxx
      @available_npa_nxx ||= client.available_npa_nxx.data
    end

    def find_npa_nxx_for(rate_center)
      available_npa_nxx.find { |data| data.rc == rate_center.name && data.region == rate_center.region && data.country == rate_center.country }
    end

    def available_numbers_for(npa:, nxx:, rate_center:)
      client.available_tns(npa:, nxx:).data.map do |number|
        PurchaseOrder::Number.new(rate_center:, order_details: number, number:, e164_format: "1#{number}")
      end
    end
  end
end
