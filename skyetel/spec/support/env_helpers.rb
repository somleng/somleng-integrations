module EnvHelpers
  def stub_env(env)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:fetch).with(any_args).and_call_original
    env.each do |key, value|
      allow(ENV).to receive(:[]).with(key).and_return(value)
      allow(ENV).to receive(:fetch).with(key, any_args).and_return(value)
    end
  end

  def stub_app_settings(settings)
    allow(AppSettings).to receive(:[]).and_call_original
    allow(AppSettings).to receive(:fetch).with(any_args).and_call_original

    settings.each do |key, value|
      allow(AppSettings).to receive(:[]).with(key).and_return(value)
      allow(AppSettings).to receive(:fetch).with(key, any_args).and_return(value)
    end
  end
end

RSpec.configure do |config|
  config.include(EnvHelpers)
end
