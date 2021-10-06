require 'spec_helper'

describe TranslationIO::Config do
  it "stores the configuration options" do
    TranslationIO.configure do |config|
      config.api_key                   = '424242'
      config.source_locale             = 'en'
      config.target_locales            = ['fr', 'nl']
      config.endpoint                  = 'http://localhost:3001/api'
      config.ignored_key_prefixes      = ['world.streets']
      config.ignored_source_paths      << 'spec/translation/'
      config.localization_key_prefixes = ['date.first_day_of_week_in_english']
      config.source_formats            << 'irb'
    end

    TranslationIO.config.api_key.should                   == '424242'
    TranslationIO.config.source_locale.should             == 'en'
    TranslationIO.config.target_locales.should            == ['fr', 'nl']
    TranslationIO.config.endpoint.should                  == 'http://localhost:3001/api'
    TranslationIO.config.ignored_key_prefixes.should      == ['world.streets']
    TranslationIO.config.localization_key_prefixes.should == ['date.first_day_of_week_in_english']
    TranslationIO.config.source_formats.should            == ['rb', 'ruby', 'rabl', 'irb']

    TranslationIO.config.source_files.should     include('lib/translation.rb')
    TranslationIO.config.source_files.should_not include('spec/support/rails_app/app/views/layouts/application.html.erb')
    TranslationIO.config.erb_source_files.should include('spec/support/rails_app/app/views/layouts/application.html.erb')
    TranslationIO.config.erb_source_files.should include('spec/support/rails_app/app/views/mailer/greetings.inky')
    TranslationIO.config.source_files.should_not include('spec/translation/config_spec.rb')
  end

  it '#source_files_for_formats - classic path naming' do
    TranslationIO.configure do |config|
      config.ignored_source_paths = ['spec/translation/', 'lib/', 'gemfiles/', '.git/']
      config.ignored_source_files = ['spec/spec_helper.rb']
    end

    TranslationIO.config.source_files.should == [
      "spec/support/rails_app/app/models/fake_model.rb",
      "spec/support/rails_app/tmp/translation/haml-gettext-00000000.rb"
    ]
  end

  it '#source_files_for_formats - second path naming ("./")' do
    TranslationIO.configure do |config|
      config.ignored_source_paths = ['./spec/translation/', './lib/', './gemfiles/', './.git/']
      config.ignored_source_files = ['./spec/spec_helper.rb']
    end

    TranslationIO.config.source_files.should == [
      "spec/support/rails_app/app/models/fake_model.rb",
      "spec/support/rails_app/tmp/translation/haml-gettext-00000000.rb"
    ]
  end

  it '#source_files_for_formats - third path naming ("no ending /")' do
    TranslationIO.configure do |config|
      config.ignored_source_paths = ['spec/translation', 'lib', 'gemfiles', '.git']
      config.ignored_source_files = ['spec/spec_helper.rb']
    end

    TranslationIO.config.source_files.should == [
      "spec/support/rails_app/app/models/fake_model.rb",
      "spec/support/rails_app/tmp/translation/haml-gettext-00000000.rb"
    ]
  end

  it '#source_files_for_formats' do
    TranslationIO.configure do |config|
      config.ignored_source_paths = ['spec', 'lib', 'gemfiles']

      config.parsed_gems = []
    end

    TranslationIO.config.source_files.size.should == 0
  end

  it '#source_files_for_formats' do
    TranslationIO.configure do |config|
      config.ignored_source_paths = ['spec', 'lib', 'gemfiles']

      config.parsed_gems = ['simplecov']
    end

    TranslationIO.config.source_files.size.should > 0
  end
end


