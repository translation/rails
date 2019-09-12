require 'spec_helper'

describe TranslationIO::Client::InitOperation::CleanupYamlFilesStep do

  it 'removes bad target files' do
    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    File.open("#{yaml_locales_path}/en.yml", 'wb') do |file|
      file.write <<-EOS
---
en:
  main:
    hello: Hello world
EOS
    end

    File.open("#{yaml_locales_path}/fr.yml", 'wb') do |file|
      file.write <<-EOS
---
fr:
  main:
    hello: Bonjour le monde
EOS
    end

    File.open("#{yaml_locales_path}/mixed.yml", 'wb') do |file|
      file.write <<-EOS
---
en:
  misc:
    yo: Yo folks
fr:
  home: "Accueil"
EOS
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::InitOperation::CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path)
    operation_step.run

    File.exist?("#{yaml_locales_path}/en.yml"   ).should be true
    File.exist?("#{yaml_locales_path}/fr.yml"   ).should be false
    File.exist?("#{yaml_locales_path}/mixed.yml").should be true

    File.read("#{yaml_locales_path}/mixed.yml").should == <<-EOS
---
en:
  misc:
    yo: Yo folks
EOS
  end

  it 'does not touch source (en.yml, etc.) or translation.XX.yml files' do
    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    source_en_yaml_data = <<-EOS
---
en:
  contact:
    title: Contact us
EOS

    translation_fr_yaml_data = <<-EOS
---
fr:
  contact:
    title: Nous contacter
EOS

    File.open("#{yaml_locales_path}/en.yml", 'wb') do |file|
      file.write(source_en_yaml_data)
    end

    File.open("#{yaml_locales_path}/translation.fr.yml", 'wb') do |file|
      file.write(translation_fr_yaml_data)
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::InitOperation::CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path)
    operation_step.run

    File.read("#{yaml_locales_path}/en.yml").should             == source_en_yaml_data
    File.read("#{yaml_locales_path}/translation.fr.yml").should == translation_fr_yaml_data
  end

  it 'does not touch source (en.yml, etc.) or localization.XX.yml files' do
    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    source_en_yaml_data = <<-EOS
---
en:
  contact:
    title: Contact us
EOS

    localization_fr_yaml_data = <<-EOS
---
fr:
  contact:
    title: Nous contacter
EOS

    File.open("#{yaml_locales_path}/source-en.yml", 'wb') do |file|
      file.write(source_en_yaml_data)
    end

    File.open("#{yaml_locales_path}/localization.fr.yml", 'wb') do |file|
      file.write(localization_fr_yaml_data)
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::InitOperation::CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path)
    operation_step.run

    File.read("#{yaml_locales_path}/source-en.yml").should       == source_en_yaml_data
    File.read("#{yaml_locales_path}/localization.fr.yml").should == localization_fr_yaml_data
  end

  it 'does not touch source (en.yml, etc.) files EXCEPT when there was other mixed languages (+ check adapting the yaml_line_width)' do
    TranslationIO.config.yaml_line_width = 20

    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    source_en_yaml_data_1 = <<-EOS
---
en:
  contact:
    title: Contact us with a particularly long message.
EOS

    File.open("#{yaml_locales_path}/en.yml", 'wb') do |file|
      file.write(source_en_yaml_data_1)
    end

    source_en_yaml_data_2 = <<-EOS
---
en:
  contact2:
    title: Contact us with a particularly long message.
fr:
  key: Why is there french in this file!?
EOS

    File.open("#{yaml_locales_path}/en-mixed.yml", 'wb') do |file|
      file.write(source_en_yaml_data_2)
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::InitOperation::CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path)
    operation_step.run

    # NOT REWRITTEN!
    en_result =  <<-EOS
---
en:
  contact:
    title: Contact us with a particularly long message.
EOS

    # REWRITTEN BECAUSE MIXED WITH OTHER LANGUAGES
    # ruby <= 2.2
    rails_2_2_mixed_result = <<-EOS
---
en:
  contact2:
    title: Contact us
      with a particularly
      long message.
EOS

    # ruby >= 2.3
    rails_2_3_mixed_result = <<-EOS
---
en:
  contact2:
    title: >-
      Contact us with
      a particularly long
      message.
EOS

    File.read("#{yaml_locales_path}/en.yml").should       ==    en_result
    File.read("#{yaml_locales_path}/en-mixed.yml").should be_in [rails_2_2_mixed_result, rails_2_3_mixed_result]
  end

end
