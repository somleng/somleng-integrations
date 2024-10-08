require "spec_helper"

module App
  RSpec.describe Handler do
    it "does something" do
      handler = build_handler
      handler.process
    end

    def build_handler(**options)
      Handler.new(event: {}, context: double("LambdaContext", as_json: {}), **options)
    end
  end
end
