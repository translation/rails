require 'spec_helper'

describe TranslationIO::Client::SyncOperation::ApplyYamlSourceEditsStep do
  it 'apply remote changes locally' do

    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    File.open("#{yaml_locales_path}/en.yml", 'wb') do |file|
      file.write <<EOS
---
en:
  main:
    hello: Hello world
EOS
    end

    File.open("#{yaml_locales_path}/en2.yml", 'wb') do |file|
      file.write <<EOS
---
en:
  other:
    hello: Hello world
    bye: Farewell
    cheet: On ne peut pas tromper mille fois
EOS
    end

    source_locale   = 'en'
    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]

    step_operation = TranslationIO::Client::SyncOperation::ApplyYamlSourceEditsStep.new(yaml_file_paths, source_locale)

    step_operation.stub(:perform_source_edits_request) do
      {
        'project_name' => "whatever",
        'project_url'  => "http://localhost:3000/somebody-that-i-used-to-know/whatever",
        'source_edits' => [
          {
            'key'      => "main.hello",
            'old_text' => "Hello world",
            'new_text' => "Hello wonderful world"
          },

          {
            'key'      => "other.cheet",
            'old_text' => "On ne peut pas tromper mille fois",
            'new_text' => "On ne peut tromper quelqu'un mille fois"
          },

          {
            'key'      => "other.bye",
            'old_text' => "Bye",
            'new_text' => "Goodbye" # won't be applied because changed locally
          },

          {
            'key'      => "other.cheet",
            'old_text' => "On ne peut tromper quelqu'un mille fois",
            'new_text' => "On ne peut tromper quelqu'un deux mille fois"
          },
        ]
      }
    end

    params = {}
    step_operation.run(params)

    File.read("#{yaml_locales_path}/en.yml").should == <<EOS
---
en:
  main:
    hello: Hello wonderful world
EOS

    File.read("#{yaml_locales_path}/en2.yml").should == <<EOS
---
en:
  other:
    hello: Hello world
    bye: Farewell
    cheet: On ne peut tromper quelqu'un deux mille fois
EOS
  end
end
