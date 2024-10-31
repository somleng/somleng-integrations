module Fibernetics
  class Configuration
    DEFAULT_API_HOST = "https://api.fibernetics.ca".freeze

    attr_accessor :api_token
    attr_writer :api_host

    def api_host
      @api_host || DEFAULT_API_HOST
    end
  end
end
