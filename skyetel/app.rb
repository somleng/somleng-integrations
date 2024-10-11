require_relative "config/application"

module App
  class Handler
    def self.process(**)
      new.process
    end

    def process
      RestockInventory.call
    end
  end
end
