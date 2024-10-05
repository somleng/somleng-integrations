require "encrypted_credentials/app_settings"
require_relative "../app/parsers/supported_cities_parser"

app_settings = Class.new(EncryptedCredentials::AppSettings) do
  def supported_cities
    @supported_cities ||= SupportedCitiesParser.new(data_file:  Pathname(File.expand_path(fetch(:supported_cities_data_file), __dir__))).parse
  end
end

AppSettings = app_settings.new(config_directory: File.expand_path(__dir__))
