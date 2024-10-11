module Skyetel
  class Configuration
    DEFAULT_API_HOST = "https://apicontrol.call48.com".freeze

    attr_accessor :username, :password
    attr_writer :api_host

    def api_host
      @api_host || DEFAULT_API_HOST
    end
  end
end
