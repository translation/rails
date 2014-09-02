require 'spec_helper'

describe TranslationIO::YAMLConversion do
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

msgctxt "helpers.label.startup<@~<attachments_attributes>@~><@~<new_attachments>@~>.permissions"
msgid "Permissions"
msgstr "permissions"

msgctxt "helpers.label.startup<@~<startup_financing_information_attributes>@~>._transaction"
msgid "Transaction"
msgstr "transaction"

msgctxt "helpers.labelarray[0].startup<@~<first_key>@~>"
msgid "Blabla"
msgstr "blabla"

msgctxt "helpers.labelarray[1].startup<@~<second_key>@~>"
msgid "Blibli"
msgstr "blibli"
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
  helpers:
    label:
      startup[attachments_attributes][new_attachments]:
        permissions: permissions
      startup[startup_financing_information_attributes]:
        _transaction: transaction
    labelarray:
    - startup[first_key]: blabla
    - startup[second_key]: blibli
EOS
    end
  end

  describe '#get_flat_translations_for_yaml_file' do
    it 'returns a flattened structure' do
      yaml_path = 'spec/support/data/en.yml'
      result    = subject.get_flat_translations_for_yaml_file(yaml_path)

      result.should == {
        "en.hello"           => "Hello world",
        "en.main.menu.stuff" => "This is stuff",
        "en.bye"             => "Good bye world",
        "en.empty"           => " "
      }
    end
  end

  describe '#get_yaml_data_from_flat_translations' do
    it 'returns unflattened yaml data' do
      flat_data = {
        "en.hello"           => "Hello world",
        "en.main.menu.stuff" => "This is stuff",
        "en.bye"             => "Good bye world",
        "en.empty"           => " "
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
  empty: " "
EOS
    end
  end
end
