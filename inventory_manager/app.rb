require_relative "config/application"

module App
  class Handler
    def self.process(**)
      new.process
    rescue StandardError => e
      Sentry.capture_exception(e)
      raise(e)
    end

    def process
      RestockInventory.call
    end
  end
end
