Somleng.configure do |config|
  config.carrier_api_key = AppSettings.fetch(:somleng_api_key)
end
