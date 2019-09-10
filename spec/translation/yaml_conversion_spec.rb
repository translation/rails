require 'spec_helper'

describe TranslationIO::YAMLConversion do
  describe 'get_yaml_data_from_po_data with inconherent keys' do
    it 'returns correct YAML data (1)' do
      po_data = <<-EOS
msgctxt "services.renting.description"
msgid "Renting is great!"
msgstr "Louer est super !"

msgctxt "services.renting.description.price.header"
msgid "What is the price?"
msgstr "Quel est le prix ?"
EOS

      yaml_data = subject.get_yaml_data_from_po_data(po_data, :fr)

      yaml_data.should == <<-EOS
---
fr:
  services:
    renting:
      description: Louer est super !
EOS
    end

    it 'returns correct YAML data (2)' do
      po_data = <<-EOS
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

      yaml_data.should == <<-EOS
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
        "en.hello"                  => "Hello world",
        "en.main.menu.stuff"        => "This is stuff",
        "en.bye"                    => "Good bye world",
        "en.empty"                  => " ",
        "en.symbol"                 => :hello,
        "en.date.order[0]"          => :day,
        "en.date.order[1]"          => :month,
        "en.date.order[2]"          => :year,
      # "en.invoice.no"             => "N°", (should not pass, 'no' is a reserved keyword in YAML)
        "en.invoice.recipient"      => "A l'attention de",
        "en.test[0].sub_test.hello" => 'hello'
      }
    end

    it 'returns an empty Hash if the YAML file is empty' do
      yaml_path = 'spec/support/data/empty.en.yml'
      result    = subject.get_flat_translations_for_yaml_file(yaml_path)

      result.should == {}
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

      expected_result_1 = <<-EOS
---
en:
  hello: Hello world
  main:
    menu:
      stuff: This is stuff
  bye: Good bye world
  empty: ' '
EOS

      expected_result_2 = <<-EOS
---
en:
  hello: Hello world
  main:
    menu:
      stuff: This is stuff
  bye: Good bye world
  empty: " "
EOS

      ((result == expected_result_1) || (result == expected_result_2)).should be true
    end

    it 'works with weird not-escaped code' do
      flat_data = {
        "en.architects.seo.image" => "<%= AController::Base.h.path('a/b.png') %>",
      }

      result = subject.get_yaml_data_from_flat_translations(flat_data)

      expected_result = <<-EOS
---
en:
  architects:
    seo:
      image: "<%= AController::Base.h.path('a/b.png') %>"
EOS

      result.should == expected_result
    end
  end
end
