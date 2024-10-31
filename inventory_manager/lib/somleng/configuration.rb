module Somleng
  class Configuration
    DEFAULT_API_HOST = "https://api.somleng.org".freeze

    attr_accessor :carrier_api_key
    attr_writer :api_host

    def api_host
      @api_host || DEFAULT_API_HOST
    end
  end
end
