require "spec_helper"

RSpec.describe ExecuteOrder do
  it "executes an order" do
    purchase_order = instance_double(PurchaseOrder, to_order: [])
    fake_client = instance_spy(Skyetel::Client)

    ExecuteOrder.call(purchase_order:, client: fake_client)

    expect(fake_client).to have_received(:purchase).with(type: :local, numbers: [])
  end
end
