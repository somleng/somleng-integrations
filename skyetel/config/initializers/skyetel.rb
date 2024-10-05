require "pry"

Skyetel.configure do |config|
  config.username = AppSettings.fetch(:skyetel_username)
  config.password = AppSettings.fetch(:skyetel_password)
end
