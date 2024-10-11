module RateCenter
  class << self
    def load(...)
      data_loader.load(...)
    end

    def unload
      @data_loader = nil
    end

    def data_loader
      @data_loader ||= DataLoader.new
    end
  end
end

require_relative "rate_center/errors"
require_relative "rate_center/data_loader"
require_relative "rate_center/city"
require_relative "rate_center/rate_center"
require_relative "rate_center/version"
