require 'spec_helper'

describe Translation::YAMLConversion::Flat do
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

      result.should == "---
en:
  hello: Hello world
  main:
    menu:
      stuff: This is stuff
  bye: Good bye world
"
    end
  end
end
