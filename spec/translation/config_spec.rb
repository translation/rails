require 'spec_helper'

describe TranslationIO::Config do
  it "stores the configuration options" do
    TranslationIO.configure do |config|
      config.api_key                   = '424242'
      config.source_locale             = :en
      config.target_locales            = [:fr, :nl]
      config.endpoint                  = 'http://localhost:3001/api'
      config.ignored_key_prefixes      = ['world.streets']
      config.localization_key_prefixes = ['date.first_day_of_week_in_english']
    end

    TranslationIO.config.api_key.should            == '424242'
    TranslationIO.config.source_locale.should      == :en
    TranslationIO.config.target_locales.should     == [:fr, :nl]
    TranslationIO.config.endpoint.should           == 'http://localhost:3001/api'
    TranslationIO.config.ignored_key_prefixes      == ['world.streets']
    TranslationIO.config.localization_key_prefixes == ['date.first_day_of_week_in_english']
  end
end


