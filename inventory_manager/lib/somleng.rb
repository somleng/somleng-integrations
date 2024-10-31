module Somleng
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

Dir["#{File.dirname(__FILE__)}/somleng/**/*.rb"].each { |f| require f }
