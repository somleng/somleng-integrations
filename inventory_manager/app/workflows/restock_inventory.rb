class RestockInventory
  def self.call(...)
    new(...).call
  end

  attr_reader :supplier, :somleng_client, :dry_run, :logger, :verbose

  def initialize(**options)
    @supplier = initialize_supplier(options.fetch(:supplier_name) { AppSettings.fetch(:supplier) })
    @somleng_client = options.fetch(:somleng_client) { Somleng::CarrierAPI::Client.new }
    @dry_run = options[:dry_run]
    @verbose = options[:verbose]
    @logger = options.fetch(:logger) { Logger.new(STDOUT) }
  end

  def call
    logger.info("Restocking inventory with options: dry_run: #{dry_run}, verbose: #{verbose}")
    inventory_report = generate_inventory_report
    shopping_list = generate_shopping_list(inventory_report)
    purchase_order = generate_purchase_order(shopping_list)
    execute_order(purchase_order)
    update_inventory(purchase_order)
  end

  private

  def initialize_supplier(supplier_name)
    case supplier_name.to_sym
    when :skyetel
      Supplier::Skyetel.new
    else
      raise "Unknown supplier: #{supplier_name}"
    end
  end

  def generate_inventory_report
    logger.info("Generating inventory report...")
    inventory_report = GenerateInventoryReport.call(client: somleng_client)
    logger.info("Done.")
    log_inventory_report(inventory_report) if verbose
    inventory_report
  end

  def generate_shopping_list(inventory_report)
    logger.info("Generating shopping list...")
    shopping_list = GenerateShoppingList.call(inventory_report:)
    logger.info("Done.")
    log_shopping_list(shopping_list) if verbose
    shopping_list
  end

  def generate_purchase_order(shopping_list)
    logger.info("Generating purchase order...")
    purchase_order = supplier.generate_purchase_order(shopping_list)
    logger.info("Done.")
    logger.info("Purchase order contains #{purchase_order.to_order.count} numbers.") if verbose
    purchase_order
  end

  def execute_order(purchase_order)
    if dry_run
      logger.info("Dry run. Skipping order execution.")
      return
    end

    logger.info("Executing order...")
    supplier.execute_order(purchase_order)
    logger.info("Done.")
  end

  def update_inventory(purchase_order)
    if dry_run
      logger.info("Dry run. Skipping inventory update.")
      return
    end

    logger.info("Updating inventory...")
    UpdateInventory.call(purchase_order:, client: somleng_client)
    logger.info("Done.")
  end

  def log_inventory_report(inventory_report)
    logger.info("Inventory report contains #{inventory_report.line_items.count} cities.")
    report_summary = inventory_report.line_items.each_with_object({}) do |line_item, result|
      result["#{line_item.country}/#{line_item.region}/#{line_item.locality}"] = line_item.quantity
    end

    logger.info("Inventory report: #{JSON.pretty_generate(report_summary)}")
  end

  def log_shopping_list(shopping_list)
    logger.info("Shopping list generated with the following options: MIN_STOCK: #{shopping_list.min_stock}, MAX_STOCK: #{shopping_list.max_stock}.")
    if shopping_list.line_items.count == 0
      logger.warn("Shopping list contains no items.")
      cities = shopping_list.cities.map { |city| "#{city.country}/#{city.region}/#{city.name}" }
      logger.info("Shopping list generated for the following cities: #{JSON.pretty_generate(cities)}")
    else
      logger.info("Shopping list contains #{shopping_list.line_items.count} items.")
      report_summary = shopping_list.line_items.each_with_object({}) do |line_item, result|
        result["#{line_item.city.country}/#{line_item.city.region}/#{line_item.city.name}"] = line_item.quantity
      end
      logger.info("Shopping list: #{JSON.pretty_generate(report_summary)}")
    end
  end
end
