module Fibernetics
  class << self
    def configure
      yield(configuration)
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration
  end
end

require_relative "fibernetics/configuration"
require_relative "fibernetics/client"
