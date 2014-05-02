require 'spec_helper'

describe Translation::YAMLConversion do
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
end
