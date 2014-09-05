YamlEntry

require 'spec_helper'

describe YamlEntry do
  describe '#string?' do
    it  do
      YamlEntry.string?('en.some.key', 'hello').should be_true
      YamlEntry.string?('en.some.key', ''     ).should be_true

      YamlEntry.string?('', 'hello'          ).should be_false
      YamlEntry.string?('en.some.key', 42    ).should be_false
      YamlEntry.string?('en.some.key', true  ).should be_false
      YamlEntry.string?('en.some.key', false ).should be_false
      YamlEntry.string?('en.some.key', :hello).should be_false
    end
  end

  describe '#from_locale?' do
    it do
      YamlEntry.from_locale?('en.some.key', 'en').should be_true
      YamlEntry.from_locale?('en.some.key', 'fr').should be_false
    end
  end

  describe '#ignored?' do
    it do
      YamlEntry.ignored?('en.faker.yo').should be_true
      YamlEntry.ignored?('en.yo').should be_false
    end
  end

  describe '#localization?' do
    it do
      YamlEntry.localization?('en.yo', 'Hello').should be_false
      YamlEntry.localization?('', 'hello'     ).should be_false

      YamlEntry.localization?('en.some.key', 42    ).should be_true
      YamlEntry.localization?('en.some.key', true  ).should be_true
      YamlEntry.localization?('en.some.key', false ).should be_true
      YamlEntry.localization?('en.some.key', :hello).should be_true

      YamlEntry.localization?('en.date.formats.default', '%Y').should be_true
      YamlEntry.localization?('en.date.order[0]', :year      ).should be_true
      YamlEntry.localization?('en.date.order[1]', :month     ).should be_true
      YamlEntry.localization?('en.date.order[2]', :day       ).should be_true
    end
  end

  describe '#localization_prefix?' do
    it do
      YamlEntry.localization_prefix?('en.date.formats.default').should be_true
      YamlEntry.localization_prefix?('en.date.order[0]'       ).should be_true
      YamlEntry.localization_prefix?('en.date.order[1]'       ).should be_true
      YamlEntry.localization_prefix?('en.date.order[2]'       ).should be_true

      YamlEntry.localization_prefix?('en.yo'                                       ).should be_false
      YamlEntry.localization_prefix?('en.number.human.decimal_units.units.thousand').should be_false
    end
  end
end
