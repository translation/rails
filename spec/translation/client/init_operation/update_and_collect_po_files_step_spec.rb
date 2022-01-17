require 'spec_helper'

describe TranslationIO::Client::InitOperation::UpdateAndCollectPoFilesStep do

  it 'creates PO files when starting from blank slate' do
    target_locales = ['fr', 'nl']
    pot_path       = 'tmp/app.pot'
    locales_path   = 'tmp'

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

msgid "Hi kids, do you like violence ?"
msgstr ""

msgid "Let's get ready to rumble!"
msgstr ""
EOS

    File.open(pot_path, 'wb') do |file|
      file.write(pot_data)
    end

    params = {}

    operation_step = TranslationIO::Client::InitOperation::UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path)
    operation_step.run(params)

    po_data_fr = <<-EOS
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"Report-Msgid-Bugs-To: \\n"
"POT-Creation-Date: 2014-06-05 17:07+0200\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: French\\n"
"Language: fr\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=2; plural=n > 1;\\n"
"\\n"

msgid "Hi kids, do you like violence ?"
msgstr ""

msgid "Let's get ready to rumble!"
msgstr ""
EOS

  po_data_nl = <<-EOS
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"Report-Msgid-Bugs-To: \\n"
"POT-Creation-Date: 2014-06-05 17:07+0200\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: Dutch\\n"
"Language: nl\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=2; plural=n != 1;\\n"
"\\n"

msgid "Hi kids, do you like violence ?"
msgstr ""

msgid "Let's get ready to rumble!"
msgstr ""
EOS

    File.read('tmp/fr/app.po').should == po_data_fr
    File.read('tmp/nl/app.po').should == po_data_nl

    params["po_data_fr"].should == po_data_fr
    params["po_data_nl"].should == po_data_nl
  end

end
