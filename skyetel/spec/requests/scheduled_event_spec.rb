require "spec_helper"

RSpec.describe "Scheduled Event" do
  it "handles scheduled events" do
    invoke_lambda(payload: {})
  end
end
