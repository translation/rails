require 'spec_helper'

describe TranslationIO::Config do
  it "stores the configuration options" do
    TranslationIO.configure do |config|
      config.api_key                   = '424242'
      config.source_locale             = :en
      config.target_locales            = [:fr, :nl]
      config.endpoint                  = 'http://localhost:3001/api'
      config.ignored_key_prefixes      = ['world.streets']
      config.ignored_source_paths      << 'spec/translation/'
      config.localization_key_prefixes = ['date.first_day_of_week_in_english']
      config.source_formats            << 'irb'
    end

    TranslationIO.config.api_key.should                   == '424242'
    TranslationIO.config.source_locale.should             == :en
    TranslationIO.config.target_locales.should            == [:fr, :nl]
    TranslationIO.config.endpoint.should                  == 'http://localhost:3001/api'
    TranslationIO.config.ignored_key_prefixes.should      == ['world.streets']
    TranslationIO.config.localization_key_prefixes.should == ['date.first_day_of_week_in_english']
    TranslationIO.config.source_formats.should            == ['rb', 'erb', 'ruby', 'rabl', 'irb']

    TranslationIO.config.source_files.should     include('lib/translation.rb')
    TranslationIO.config.source_files.should     include('spec/support/rails_app/app/views/layouts/application.html.erb')
    TranslationIO.config.source_files.should_not include('spec/translation/config_spec.rb')
  end
end


