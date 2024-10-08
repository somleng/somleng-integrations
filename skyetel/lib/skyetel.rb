module Skyetel
  class << self
    def configure
      yield(configuration)
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

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

require_relative "skyetel/configuration"
require_relative "skyetel/client"
require_relative "skyetel/errors"
require_relative "skyetel/rate_center"
require_relative "skyetel/data_loader"
