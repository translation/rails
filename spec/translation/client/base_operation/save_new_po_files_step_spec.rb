require 'spec_helper'

describe TranslationIO::Client::BaseOperation::SaveNewPoFilesStep do

  it do
    source_locale  = 'en'
    target_locales = ['fr', 'nl']
    locales_path   = 'tmp'

    pot_path = File.join(locales_path, "app.pot")
    FileUtils.rm(pot_path) if File.exist?(pot_path)
    FileUtils.mkdir_p(File.dirname(pot_path))

    pot_data = <<-EOS
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"Report-Msgid-Bugs-To: \\n"
"POT-Creation-Date: 2014-06-05 17:07+0200\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL@li.org>\\n"
"Language: \\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=INTEGER; plural=EXPRESSION;\\n"

msgid "Hello world"
msgstr ""

msgid "Hello young man"
msgid_plural "Hello young men"
msgstr[0] ""
msgstr[1] ""
EOS

    File.open(pot_path, 'wb') do |file|
      file.write(pot_data)
    end

    po_data_fr = <<-EOS
msgid ""
msgstr ""

msgid "Hello world"
msgstr "Bonjour le monde"

msgid "Hello young man"
msgid_plural "Hello young men"
msgstr[0] "Bonjour jeune homme"
msgstr[1] "Bonjour jeunes hommes"
EOS

    po_data_nl = <<-EOS
msgid ""
msgstr ""

msgid "Hello world"
msgstr "Hallo wereld"

msgid "Hello young man"
msgid_plural "Hello young men"
msgstr[0] "Hallo jongeman"
msgstr[1] "Hallo jonge mannen"
EOS

    parsed_response = {
      'po_data_fr' => po_data_fr,
      'po_data_nl' => po_data_nl
    }

    operation_step = TranslationIO::Client::BaseOperation::SaveNewPoFilesStep.new(source_locale, target_locales, locales_path, parsed_response)
    operation_step.run

    # Check that target PO files are correctly saved
    File.read('tmp/fr/app.po').should == po_data_fr
    File.read('tmp/nl/app.po').should == po_data_nl

    # Check that source PO is correctly completed (target = source) and saved
    File.read('tmp/en/app.po').should == <<-EOS
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"Report-Msgid-Bugs-To: \\n"
"POT-Creation-Date: 2014-06-05 17:07+0200\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: English\\n"
"Language: en\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=; plural=;\\n"
"\\n"

msgid "Hello world"
msgstr "Hello world"

msgid "Hello young man"
msgid_plural "Hello young men"
msgstr[0] "Hello young man"
msgstr[1] "Hello young men"
EOS
  end
end
