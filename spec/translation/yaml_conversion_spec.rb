require 'spec_helper'

describe TranslationIO::YAMLConversion do
  describe '#get_pot_data_from_yaml' do
    it 'returns correct PO data' do
      po_data = subject.get_pot_data_from_yaml(:en, [
        'spec/support/data/en.yml'
      ])

      po_data.should == <<EOS
msgctxt "hello"
msgid "Hello world"
msgstr ""

msgctxt "main.menu.stuff"
msgid "This is stuff"
msgstr ""

msgctxt "bye"
msgid "Good bye world"
msgstr ""
EOS
    end
  end

  describe '#get_yaml_data_from_po_data' do
    it 'returns correct YAML data' do
      po_data = <<EOS
msgctxt "hello"
msgid "Hello world"
msgstr "Bonjour le monde entier"

msgctxt "main.menu.stuff"
msgid "This is stuff"
msgstr "Ce sont des choses"

msgctxt "bye"
msgid "Good bye world"
msgstr "Au revoir le monde"
EOS

      yaml_data = subject.get_yaml_data_from_po_data(po_data, :fr)

      yaml_data.should == <<EOS
---
fr:
  hello: Bonjour le monde entier
  main:
    menu:
      stuff: Ce sont des choses
  bye: Au revoir le monde
EOS
    end
  end

  describe '#get_flat_translations_for_locale' do
    it do
      result = subject.get_flat_translations_for_locale(:en, [
        'spec/support/data/en.yml'
      ])

      result.should == {
        "en.hello"           => "Hello world",
        "en.main.menu.stuff" => "This is stuff",
        "en.bye"             => "Good bye world"
      }
    end
  end

  describe '#get_flat_translations_for_yaml_file' do
    it 'returns a flattened structure' do
      yaml_path = 'spec/support/data/en.yml'
      result    = subject.get_flat_translations_for_yaml_file(yaml_path)

      result.should == {
        "en.hello"           => "Hello world",
        "en.main.menu.stuff" => "This is stuff",
        "en.bye"             => "Good bye world"
      }
    end
  end

  describe '#get_yaml_data_from_flat_translations' do
    it 'returns unflattened yaml data' do
      flat_data = {
        "en.hello"           => "Hello world",
        "en.main.menu.stuff" => "This is stuff",
        "en.bye"             => "Good bye world"
      }

      result = subject.get_yaml_data_from_flat_translations(flat_data)

      result.should == <<EOS
---
en:
  hello: Hello world
  main:
    menu:
      stuff: This is stuff
  bye: Good bye world
EOS
    end
  end
end
