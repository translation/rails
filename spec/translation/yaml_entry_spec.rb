TranslationIO::YamlEntry

require 'spec_helper'

describe TranslationIO::YamlEntry do
  describe '#string?' do
    it  do
      TranslationIO::YamlEntry.string?('en.some.key', 'hello').should be true
      TranslationIO::YamlEntry.string?('en.some.key', ''     ).should be true

      TranslationIO::YamlEntry.string?('', 'hello'          ).should be false
      TranslationIO::YamlEntry.string?('en.some.key', 42    ).should be false
      TranslationIO::YamlEntry.string?('en.some.key', true  ).should be false
      TranslationIO::YamlEntry.string?('en.some.key', false ).should be false
      TranslationIO::YamlEntry.string?('en.some.key', :hello).should be false
    end
  end

  describe '#from_locale?' do
    it do
      TranslationIO::YamlEntry.from_locale?('en.some.key', 'en').should be true
      TranslationIO::YamlEntry.from_locale?('en.some.key', 'fr').should be false
    end
  end

  describe '#ignored?' do
    context 'when using a string' do
      it do
        TranslationIO::YamlEntry.ignored?('en.faker.yo').should be true
        TranslationIO::YamlEntry.ignored?('en.faker').should be true
        TranslationIO::YamlEntry.ignored?('en.faker.aa.aa.bb').should be true
        TranslationIO::YamlEntry.ignored?('en.yo').should be false
        TranslationIO::YamlEntry.ignored?('en.fakeryo').should be false
        TranslationIO::YamlEntry.ignored?('fr.faker').should be true

        TranslationIO.config.ignored_key_prefixes = ['world']

        TranslationIO::YamlEntry.ignored?('en.world').should be true
        TranslationIO::YamlEntry.ignored?('en.world.hello').should be true
        TranslationIO::YamlEntry.ignored?('en.worldbla').should be false
        TranslationIO::YamlEntry.ignored?('fr.world.hello').should be true

        TranslationIO.config.ignored_key_prefixes = ['world.']

        TranslationIO::YamlEntry.ignored?('en.world').should be false
        TranslationIO::YamlEntry.ignored?('en.world.hello').should be true
        TranslationIO::YamlEntry.ignored?('en.worldbla').should be false
        TranslationIO::YamlEntry.ignored?('fr.world.hello').should be true

        # check "." on ignored key prefix is not used as special char in the regexp
        TranslationIO::YamlEntry.ignored?('fr.worlda').should be false
      end
    end

    context 'when using a regular expression' do
      it do
        TranslationIO::YamlEntry.ignored?('en.faker.yo').should be true
        TranslationIO::YamlEntry.ignored?('en.faker').should be true
        TranslationIO::YamlEntry.ignored?('en.faker.aa.aa.bb').should be true
        TranslationIO::YamlEntry.ignored?('en.yo').should be false
        TranslationIO::YamlEntry.ignored?('en.fakeryo').should be false
        TranslationIO::YamlEntry.ignored?('fr.faker').should be true

        TranslationIO.config.ignored_key_prefixes = [
          /\.do_not_translate$/,
          /^world$|^world\..+$/,
        ]

        TranslationIO::YamlEntry.ignored?('en.world').should be true
        TranslationIO::YamlEntry.ignored?('en.world.hello').should be true
        TranslationIO::YamlEntry.ignored?('en.worldbla').should be false
        TranslationIO::YamlEntry.ignored?('fr.world.hello').should be true
        TranslationIO::YamlEntry.ignored?('fr.yet.another.world.hello').should be false
        TranslationIO::YamlEntry.ignored?('fr.mars.hello.do_not_translate').should be true
      end
    end

    context 'when using a mix of regular expression and strings' do
      it do
        TranslationIO.config.ignored_key_prefixes = [
          /\.do_not_translate$/,
          /^world$|^world\..+$/,
          "mars"
        ]

        TranslationIO::YamlEntry.ignored?('en.world').should be true
        TranslationIO::YamlEntry.ignored?('en.world.hello').should be true
        TranslationIO::YamlEntry.ignored?('en.worldbla').should be false
        TranslationIO::YamlEntry.ignored?('fr.world.hello').should be true
        TranslationIO::YamlEntry.ignored?('fr.yet.another.world.hello').should be false
        TranslationIO::YamlEntry.ignored?('fr.mars.hello').should be true
        TranslationIO::YamlEntry.ignored?('fr.mars.hello.do_not_translate').should be true
        TranslationIO::YamlEntry.ignored?('fr.mars_attacks.world').should be false
      end
    end
  end

  describe '#localization?' do
    it do
      TranslationIO::YamlEntry.localization?('en.yo', 'Hello').should be false
      TranslationIO::YamlEntry.localization?('', 'hello'     ).should be false

      TranslationIO::YamlEntry.localization?('en.some.key', 42    ).should be true
      TranslationIO::YamlEntry.localization?('en.some.key', true  ).should be true
      TranslationIO::YamlEntry.localization?('en.some.key', false ).should be true
      TranslationIO::YamlEntry.localization?('en.some.key', :hello).should be true

      TranslationIO::YamlEntry.localization?('en.date.formats.default', '%Y').should be true
      TranslationIO::YamlEntry.localization?('en.date.order[0]', :year      ).should be true
      TranslationIO::YamlEntry.localization?('en.date.order[1]', :month     ).should be true
      TranslationIO::YamlEntry.localization?('en.date.order[2]', :day       ).should be true

      TranslationIO::YamlEntry.localization?('en.i18n.transliterate.rule.æ', "ae" ).should be true

      TranslationIO.config.localization_key_prefixes = ['date.first_day_of_week_in_english']
      TranslationIO::YamlEntry.localization?('en.date.first_day_of_week_in_english', 'monday').should be true

      # check "." on ignored key prefix is not used as special char in the regexp
      TranslationIO.config.localization_key_prefixes = ['date.']
      TranslationIO::YamlEntry.localization?('en.date2', 'monday').should be false
    end
  end

  describe '#localization_prefix?' do
    it do
      TranslationIO::YamlEntry.localization_prefix?('en.date.formats.default').should be true
      TranslationIO::YamlEntry.localization_prefix?('en.date.formatsss.default').should be false
      TranslationIO::YamlEntry.localization_prefix?('en.date.order[0]').should be true
      TranslationIO::YamlEntry.localization_prefix?('en.date.order[1]').should be true
      TranslationIO::YamlEntry.localization_prefix?('en.date.order[2]').should be true
      TranslationIO::YamlEntry.localization_prefix?('en.date.orders[2]').should be false

      TranslationIO::YamlEntry.localization_prefix?('en.yo').should be false
      TranslationIO::YamlEntry.localization_prefix?('en.number.human.decimal_units.units.thousand').should be false
    end
  end
end
