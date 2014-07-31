require 'spec_helper'

describe TranslationIO::Client::InitOperation::CleanupYamlFilesStep do

  it 'removes bad target files' do
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

    File.open("#{yaml_locales_path}/fr.yml", 'wb') do |file|
      file.write <<EOS
---
fr:
  main:
    hello: Bonjour le monde
EOS
    end

    File.open("#{yaml_locales_path}/mixed.yml", 'wb') do |file|
      file.write <<EOS
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

    File.exist?("#{yaml_locales_path}/en.yml"   ).should be_true
    File.exist?("#{yaml_locales_path}/fr.yml"   ).should be_false
    File.exist?("#{yaml_locales_path}/mixed.yml").should be_true

    File.read("#{yaml_locales_path}/mixed.yml").should == <<EOS
---
en:
  misc:
    yo: Yo folks
EOS
  end

  it 'does not touch translation.XX.yml files' do
    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    translation_en_yaml_data = <<EOS
---
en:
  contact:
    title: Contact us
EOS

    translation_fr_yaml_data = <<EOS
---
en:
  contact:
    title: Nous contacter
EOS

    File.open("#{yaml_locales_path}/translation.en.yml", 'wb') do |file|
      file.write(translation_en_yaml_data)
    end

    File.open("#{yaml_locales_path}/translation.fr.yml", 'wb') do |file|
      file.write(translation_fr_yaml_data)
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::InitOperation::CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path)
    operation_step.run

    File.read("#{yaml_locales_path}/translation.en.yml").should == translation_en_yaml_data
    File.read("#{yaml_locales_path}/translation.fr.yml").should == translation_fr_yaml_data
  end

  it 'does not touch localization.XX.yml files' do
    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    localization_en_yaml_data = <<EOS
---
en:
  contact:
    title: Contact us
EOS

    localization_fr_yaml_data = <<EOS
---
en:
  contact:
    title: Nous contacter
EOS

    File.open("#{yaml_locales_path}/localization.en.yml", 'wb') do |file|
      file.write(localization_en_yaml_data)
    end

    File.open("#{yaml_locales_path}/localization.fr.yml", 'wb') do |file|
      file.write(localization_fr_yaml_data)
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::InitOperation::CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path)
    operation_step.run

    File.read("#{yaml_locales_path}/localization.en.yml").should == localization_en_yaml_data
    File.read("#{yaml_locales_path}/localization.fr.yml").should == localization_fr_yaml_data
  end

end
