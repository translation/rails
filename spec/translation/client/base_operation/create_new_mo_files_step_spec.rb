# coding: utf-8

require 'spec_helper'

describe TranslationIO::Client::BaseOperation::CreateNewMoFilesStep do
  it do
    locales_path = 'tmp/config/locales/gettext'

    FileUtils.mkdir_p("#{locales_path}/fr")
    FileUtils.mkdir_p("#{locales_path}/nl")

    po_data_fr = <<-EOS
msgid "Hi kids, do you like violence ?"
msgstr "Salut les enfants, vous aimez la violence?"

msgid "Let's get ready to rumble !"
msgstr "C'est parti pour la baston!"
EOS

    File.open("#{locales_path}/fr/app.po", 'wb') do |file|
      file.write(po_data_fr)
    end

    step_operation = TranslationIO::Client::BaseOperation::CreateNewMoFilesStep.new(locales_path)
    step_operation.run

    File.exist?('tmp/config/locales/gettext/fr/LC_MESSAGES/app.mo').should be true
  end
end
