require 'spec_helper'

describe Translation::Client::InitOperation::CreateYamlPoFilesStep do

  it do
    yaml_root_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_root_path)

    File.open('tmp/config/locales/en.yml', 'wb') do |file|
      file.write <<EOS
---
en:
  home:
    show:
      title: "Awesome Title"
EOS
    end

        File.open('tmp/config/locales/fr.yml', 'wb') do |file|
      file.write <<EOS
---
fr:
  home:
    show:
      title: "Titre génial"
EOS
    end

    source_locale   = 'en'
    target_locales  = ['fr', 'nl']
    yaml_file_paths = Dir["#{yaml_root_path}/*.yml"]
    params          = {}

    operation_step = Translation::Client::InitOperation::CreateYamlPoFilesStep.new(source_locale, target_locales, yaml_file_paths)
    operation_step.run(params)

    params['yaml_po_data_fr'].should == <<EOS
msgctxt "home.show.title"
msgid "Awesome Title"
msgstr "Titre génial"
EOS

    params['yaml_po_data_nl'].should == <<EOS
msgctxt "home.show.title"
msgid "Awesome Title"
msgstr ""
EOS
  end

end
