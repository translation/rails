require 'spec_helper'

describe Translation::YAMLConversion::Flat do
  describe '#get_flat_translations_for_locale' do
  end

  describe '#get_flat_translations_for_yaml_file' do
    it 'returns a flattened structure' do
      yaml_path = 'spec/support/data/en.yml'
      result    = subject.get_flat_translations_for_yaml_file(yaml_path)

      result.should == {
        "en.hello"           => { :locale_file_path => "spec/support/data/en.yml", :translation => "Hello world"    },
        "en.main.menu.stuff" => { :locale_file_path => "spec/support/data/en.yml", :translation => "This is stuff"  },
        "en.bye"             => { :locale_file_path => "spec/support/data/en.yml", :translation => "Good bye world" }
      }
    end
  end

  describe '#get_yaml_from_flat_yaml' do
    it 'returns unflattened yaml data' do
      flat_data = {
        "en.hello"           => "Hello world",
        "en.main.menu.stuff" => "This is stuff",
        "en.bye"             => "Good bye world"
      }

      result = subject.get_yaml_from_flat_yaml(flat_data)

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
