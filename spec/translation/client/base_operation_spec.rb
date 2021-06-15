require 'spec_helper'

describe TranslationIO::Client::BaseOperation do
  it 'has default values initialized' do
    TranslationIO.configure do |config|
      config.target_locales = ['fr', 'nl']
    end

    client    = TranslationIO::Client.new('4242', 'bidule.com/api')
    operation = TranslationIO::Client::BaseOperation.new(client)

    operation.client.should == client
  end

  describe 'Locale inconsistency warnings' do
    it 'triggers error if config.target_locales has duplicate locale' do
      TranslationIO.configure do |config|
        config.source_locale  = :en
        config.target_locales = [:fr, :nl, :fr]
      end

      client = TranslationIO::Client.new('4242', 'https://translation.io')

      randomOperation = [
        TranslationIO::Client::InitOperation,
        TranslationIO::Client::SyncOperation
      ].sample

      expect { randomOperation.new(client).run}.to raise_error(SystemExit).and output(<<EOS

----------
Your `config.target_locales` has a duplicate locale (fr).
Please clean your configuration file and execute this command again.
----------
EOS
      ).to_stdout
    end

    it 'triggers error if config.source_locale in included in config.target_locales' do
      TranslationIO.configure do |config|
        config.source_locale  = :en
        config.target_locales = [:fr, :en, :nl]
      end

      client = TranslationIO::Client.new('4242', 'https://translation.io')

      randomOperation = [
        TranslationIO::Client::InitOperation,
        TranslationIO::Client::SyncOperation
      ].sample

      expect { randomOperation.new(client).run }.to raise_error(SystemExit).and output(<<EOS

----------
The `config.source_locale` (en) can't be included in the `config.target_locales`.
If you want to customize your source locale, check this link: https://github.com/translation/rails#custom-languages
Please clean your configuration file and execute this command again.
----------
EOS
      ).to_stdout
    end

    it 'triggers error if config.target_locales is empty' do
      TranslationIO.configure do |config|
        config.source_locale  = :en
        config.target_locales = []
      end

      client = TranslationIO::Client.new('4242', 'https://translation.io')

      randomOperation = [
        TranslationIO::Client::InitOperation,
        TranslationIO::Client::SyncOperation
      ].sample

      expect { randomOperation.new(client).run }.to raise_error(SystemExit).and output(<<EOS

----------
Your `config.target_locales` is empty.
Please clean your configuration file and execute this command again.
----------
EOS
      ).to_stdout
    end
  end
end
