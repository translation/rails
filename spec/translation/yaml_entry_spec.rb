TranslationIO::YamlEntry

require 'spec_helper'

describe TranslationIO::YamlEntry do
  describe '#string?' do
    it  do
      TranslationIO::YamlEntry.string?('en.some.key', 'hello').should be_true
      TranslationIO::YamlEntry.string?('en.some.key', ''     ).should be_true

      TranslationIO::YamlEntry.string?('', 'hello'          ).should be_false
      TranslationIO::YamlEntry.string?('en.some.key', 42    ).should be_false
      TranslationIO::YamlEntry.string?('en.some.key', true  ).should be_false
      TranslationIO::YamlEntry.string?('en.some.key', false ).should be_false
      TranslationIO::YamlEntry.string?('en.some.key', :hello).should be_false
    end
  end

  describe '#from_locale?' do
    it do
      TranslationIO::YamlEntry.from_locale?('en.some.key', 'en').should be_true
      TranslationIO::YamlEntry.from_locale?('en.some.key', 'fr').should be_false
    end
  end

  describe '#ignored?' do
    it do
      TranslationIO::YamlEntry.ignored?('en.faker.yo').should be_true
      TranslationIO::YamlEntry.ignored?('en.yo').should be_false
    end
  end

  describe '#localization?' do
    it do
      TranslationIO::YamlEntry.localization?('en.yo', 'Hello').should be_false
      TranslationIO::YamlEntry.localization?('', 'hello'     ).should be_false

      TranslationIO::YamlEntry.localization?('en.some.key', 42    ).should be_true
      TranslationIO::YamlEntry.localization?('en.some.key', true  ).should be_true
      TranslationIO::YamlEntry.localization?('en.some.key', false ).should be_true
      TranslationIO::YamlEntry.localization?('en.some.key', :hello).should be_true

      TranslationIO::YamlEntry.localization?('en.date.formats.default', '%Y').should be_true
      TranslationIO::YamlEntry.localization?('en.date.order[0]', :year      ).should be_true
      TranslationIO::YamlEntry.localization?('en.date.order[1]', :month     ).should be_true
      TranslationIO::YamlEntry.localization?('en.date.order[2]', :day       ).should be_true
    end
  end

  describe '#localization_prefix?' do
    it do
      TranslationIO::YamlEntry.localization_prefix?('en.date.formats.default').should be_true
      TranslationIO::YamlEntry.localization_prefix?('en.date.order[0]'       ).should be_true
      TranslationIO::YamlEntry.localization_prefix?('en.date.order[1]'       ).should be_true
      TranslationIO::YamlEntry.localization_prefix?('en.date.order[2]'       ).should be_true

      TranslationIO::YamlEntry.localization_prefix?('en.yo'                                       ).should be_false
      TranslationIO::YamlEntry.localization_prefix?('en.number.human.decimal_units.units.thousand').should be_false
    end
  end
end
